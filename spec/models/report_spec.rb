require "spec_helper"

describe Report do

  it 'has a random uri by default' do
    subject.uri.should_not be_nil
    Report.new.uri.should_not == Report.new.uri
  end

  it 'has a sensible graph uri by default' do
    subject.graph_uri.should_not be_nil
    subject.graph_uri.should == Report.graph_uri
  end

  it 'has a sensible rdf_type by default' do
    subject.rdf_type.should_not be_nil
    subject.rdf_type.should == Report.rdf_type
  end

  context 'with a missing label' do
    it 'validation should set it!' do
      subject.label = nil
      subject.valid?
      subject.label.should_not be_empty
    end
  end

  context 'with a missing incident' do
    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:incident].should_not be_empty
      subject.errors[:incident].should include("can't be blank")
    end
  end


  context 'with everything OK' do

    subject do
      r= Report.new()
      r.incident = FactoryGirl.create(:incident)
      r
    end

    it 'is valid' do
      subject.should be_valid
    end
  end

  describe ".all" do

    before do
      r = Report.new()
      r.incident = FactoryGirl.create(:incident)
      r.save!

      r2 = Report.new()
      r2.incident = FactoryGirl.create(:incident)
      r2.save!
    end

    it "returns all the reports" do
      Report.all.length.should == 2
    end

  end


  describe "#creator=" do
    it 'sets the associated user for this report' do
      user = FactoryGirl.create(:user)
      subject.creator = user
      subject.creator.should == user
      subject[Report.creator_predicate].first.to_s.should == user.uri.to_s
    end
  end

  describe "#creator" do
    context "when there's an assocated reporter" do

      subject do
        @user = FactoryGirl.create(:user)
        r = Report.new
        r.creator = @user
        r
      end

      it 'returns the associated report type object' do
        subject.creator.should == @user
      end
    end

    context "when there's no associated reporter" do
      it "returns nil" do
        subject.creator.should be_nil
      end
    end
  end

  describe ".delete_all" do
    it "deletes all reports" do
      r = Report.new()
      r.incident = FactoryGirl.create(:incident)
      r.save!

      Report.all.length.should be > 0
      Report.delete_all_from_graph
      Report.all.length.should == 0
    end
  end

  describe "open_reports" do

    it "should return open ended or still-open reports" do

      Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

      #check no reports before we start
      Report.all.length.should == 0
      initial_open_reports = Report.open_reports
      initial_open_reports.length.should == 0

      # this one ends in the future
      report1 = Report.new
      incident1 = FactoryGirl.build(:incident)
      interval1 = FactoryGirl.build(:interval)
      place1 = FactoryGirl.build(:place)

      report1.incident = incident1
      incident1.place = place1
      interval1.begins_at = Time.now
      interval1.ends_at = Time.now.advance(:days => 1)
      incident1.interval = interval1

      report1.save_report_and_children.should == true # should save

      # this one doesn't end
      report2 = Report.new
      incident2 = FactoryGirl.build(:incident)
      interval2 = FactoryGirl.build(:interval)
      place2 = FactoryGirl.build(:place)

      report2.incident = incident2
      incident2.place = place2
      interval2.ends_at.should == nil
      incident2.interval = interval2

      report2.save_report_and_children.should == true # should save

      # this one has ended.
      report3 = Report.new
      incident3 = FactoryGirl.build(:incident)
      interval3 = FactoryGirl.build(:interval)
      place3 = FactoryGirl.build(:place)

      report3.incident = incident3
      incident3.place = place3
      interval3.ends_at = Time.now.advance(:days => -1)
      incident3.interval = interval3

      report3.save_report_and_children.should == true # should save

      open_reports = Report.open_reports.map {|r| r.uri.to_s }
      open_reports.class.should == Array

      open_reports.should include(report1.uri.to_s)
      open_reports.should include(report2.uri.to_s)
      open_reports.should_not include(report3.uri.to_s)

      open_reports.length.should == 2
    end
  end

  describe "create report and children in a transaction" do

    # this is just testing my transaction pattern works!

    context "everything works" do

      before do

        Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

        @interval = Interval.new()
        @incident = Incident.new()
        @place = Place.new()
        @report = Report.new()

        # this is in aberdeen
        @place.latitude = 57.15
        @place.longitude = -2.10

        @incident.description = 'hello'
        @report.incident = @incident
        @incident.place = @place
        @incident.interval = @interval

        t = Tripod::Persistence::Transaction.new

        success = @report.save_report_and_children(transaction: t)

        success.should be_true # all works

        if success
          t.commit
        else
          t.abort
        end
      end

      it "should save everything" do

        Report.all.length.should be > 0
        Incident.all.length.should be > 0
        Place.all.length.should be > 0
        Interval.all.length.should be > 0

        @report.incident.should == @incident
        @incident.place.should == @place
        @incident.interval.should == @interval

      end

    end

    context "something fails" do

      before do

        Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

        @interval = Interval.new()
        @incident = Incident.new()
        @place = Place.new()
        @report = Report.new()

        @place.latitude = 53.1
        @place.longitude = 'bleh' #dodgy!

        @incident.description = 'hello'

        @report.incident = @incident
        @incident.place = @place
        @incident.interval = @interval

        t = Tripod::Persistence::Transaction.new

        success = @report.save_report_and_children(transaction: t)

        @report.errors[:location].should_not be_empty

        success.should be_false # place longitude causes validation fail

        if success
          t.commit
        else
          t.abort
        end
      end

      it "should save nothing" do
        Report.all.length.should == 0
        Incident.all.length.should == 0
        Place.all.length.should == 0
        Interval.all.length.should == 0
      end
    end

  end



end