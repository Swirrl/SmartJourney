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
    it 'is invalid' do
      subject.label = nil
      subject.should_not be_valid
      subject.errors[:label].should_not be_empty
      subject.errors[:label].should include("can't be blank")
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
      Report.delete_all
      Report.all.length.should == 0
    end
  end

  describe "create report and children in a transaction" do

    # this is just testing my transaction pattern works!

    context "everything works" do

      before do
        @interval = Interval.new()
        @incident = Incident.new()
        @place = Place.new()
        @report = Report.new()

        @place.latitude = 53.1
        @place.longitude = 2.1

        @incident.description = 'hello'

        @report.incident = @incident
        @place.associate_zone()
        @incident.place = @place
        @incident.interval = @interval
        @interval.begins_at = @report.created_at

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
        @interval = Interval.new()
        @incident = Incident.new()
        @place = Place.new()
        @report = Report.new()

        @place.latitude = 53.1
        @place.longitude = 'bleh' #dodgy!

        @incident.description = 'hello'

        @report.incident = @incident
        @place.associate_zone()
        @incident.place = @place
        @incident.interval = @interval
        @interval.begins_at = @report.created_at

        t = Tripod::Persistence::Transaction.new

        success = @report.save_report_and_children(transaction: t)

        @report.errors[:longitude].should_not be_empty

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