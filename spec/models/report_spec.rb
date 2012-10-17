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
      FactoryGirl.build(:report)
    end

    it 'is valid' do
      subject.should be_valid
    end
  end

  describe ".all" do

    before do
      r = FactoryGirl.build(:report)
      r.save.should be_true

      r2 = FactoryGirl.build(:report)
      r2.save.should be_true
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
      r = FactoryGirl.build(:report)
      r.save.should be_true

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
      @report1 = Report.new()
      @report1.latitude = 57.15
      @report1.longitude = -2.1
      @report1.description = 'hello'
      @report1.incident_ends_at = Time.now.advance(:days => 1)
      @report1.save.should be_true

      # this one doesn't end
      @report2 = Report.new()
      @report2.latitude = 57.15
      @report2.longitude = -2.1
      @report2.description = 'hello'
      @report2.save.should be_true

      # this one has ended.
      @report3 = Report.new()
      @report3.latitude = 57.15
      @report3.longitude = -2.1
      @report3.description = 'hello'
      @report3.incident_ends_at = Time.now.advance(:days => -1)
      @report3.save.should be_true

      open_reports = Report.open_reports.map {|r| r.uri.to_s }
      open_reports.class.should == Array

      open_reports.should include(@report1.uri.to_s)
      open_reports.should include(@report2.uri.to_s)
      open_reports.should_not include(@report3.uri.to_s)

      open_reports.length.should == 2
    end
  end

  describe 'save' do

    context "everything works" do

      before do
        Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

        @report = Report.new()
        @report.latitude = 57.15
        @report.longitude = -2.1
        @report.description = 'hello'
        @report.incident_ends_at = '2013-01-01'
        @report.save.should be_true
      end

      it "should save everything" do
        Report.all.length.should be > 0
        Incident.all.length.should be > 0
        Place.all.length.should be > 0
        Interval.all.length.should be > 0

        report = Report.all.first
        report.incident.should == Incident.all.first
        report.incident.place.should == Place.all.first
        report.incident.interval.should == Interval.all.first

        # check values are saved ok.
        report.latitude.should == "57.15"
        report.longitude.should == "-2.1"
        report.description.should == 'hello'

        begins = Time.parse(report.incident_begins_at).to_s(:long)
        created_at = Time.parse(report.created_at).to_s(:long)

        begins.should == created_at
        Time.parse(report.incident_ends_at).to_s(:long).should == Time.parse('2013-01-01').to_s(:long)

      end

    end

    context 'with no begins specified' do

      subject do
        Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

        report = Report.new()
        report.latitude = 57.15
        report.longitude = -2.1
        report.description = 'hello'
        report.incident_ends_at = '2013-01-01'
        report.save.should be_true
        report
      end

      it 'should set it to created date' do
        Time.parse(subject.incident_begins_at).to_s(:long).should == Time.parse(subject.created_at).to_s(:long)
      end

    end

    it "should round lat longs to 6 dp" do
      subject.latitude = 57.151231514125123
      subject.longitude = -2.1123124124213
      subject.description = 'hello'
      subject.save.should be_true

      report = Report.all.first
      report.latitude.should == "57.151232"
      report.longitude.should == "-2.112312"
    end

    it "should set a created date automatically" do
      r = FactoryGirl.build(:report)
      r.save.should be_true
      r.created_at.should_not be_nil
    end

    it "should set a zone" do
      r = FactoryGirl.build(:report)
      r.save.should be_true
      r.zone.should_not be_nil
    end

    context 'with a user assigned' do

      subject do
        r = FactoryGirl.build(:report)
        r.creator = FactoryGirl.create(:user)
        r
      end

      it 'should include the user in the label' do
        subject.save.should be_true
        subject.label.should == "Report: hello this is a v..., created #{Time.parse(subject.created_at).to_s(:long)} by ricroberts"
      end

    end

    context 'without a user assigned' do

      subject do
        r = FactoryGirl.build(:report)
      end

      it 'should not include the user in the label' do
        subject.save.should be_true
        subject.label.should == "Report: hello this is a v..., created #{Time.parse(subject.created_at).to_s(:long)}"
      end

    end

    context "something fails" do

      before do
        Zone.should_receive(:zone_for_lat_long).at_least(:once).and_return(Zone.all.first)

        @report = Report.new()
        @report.latitude = 57.15
        @report.longitude = 'bleh' #dodgy!
        @report.description = 'hello'
        @report.save.should be_false # fail!

        @report.errors[:location].should_not be_empty
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