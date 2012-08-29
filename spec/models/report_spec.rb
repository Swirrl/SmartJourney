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
    subject[RDF.type].should_not be_empty
    subject[RDF.type].first.should == Report.rdf_type
  end

  it 'has a default datetime set' do
    subject.datetime.should be_present
  end

  context 'with a missing datetime' do

    before do
      subject.datetime = nil
    end

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:datetime].should_not be_empty
      subject.errors[:datetime].should include("can't be blank")
    end

  end

  context 'with an invalid datetime' do

    subject do
      r = Report.new()
      r.datetime = 'bleh'
      r
    end

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:datetime].should_not be_empty
      subject.errors[:datetime].should include("is invalid")
    end

  end

  context 'with a missing latitude' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:latitude].should_not be_empty
      subject.errors[:latitude].should include("can't be blank")
    end

  end

  context 'with a missing longitude' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:longitude].should_not be_empty
      subject.errors[:longitude].should include("can't be blank")
    end

  end

  context 'with an invalid longitude' do

    subject do
      r = Report.new()
      r.longitude = 'bleh'
      r
    end

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:longitude].should_not be_empty
      subject.errors[:longitude].should include("is invalid")
    end

  end

  context 'with an invalid latitude' do

    subject do
      r = Report.new()
      r.latitude = 'bleh'
      r
    end

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:latitude].should_not be_empty
      subject.errors[:latitude].should include("is invalid")
    end

  end

  context 'without a zone' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:zone].should_not be_empty
      subject.errors[:zone].should include("can't be blank")
    end

  end

  context 'without a report type' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:report_type].should_not be_empty
      subject.errors[:report_type].should include("can't be blank")
    end

  end

  context 'with everything OK' do

    subject do
      r1 = Report.new()
      r1.description = 'foobar'
      r1.datetime = Date.new(2011,1,1)
      r1.latitude = 2.1
      r1.longitude = 53.1
      r1.zone = Zone.new('http://zoney')
      r1.report_type = ReportType.new('http://reporttype1')
      r1.save!
      r1
    end

    it 'is valid' do
      subject.should be_valid
    end
  end

  describe ".all" do

    before do
      # make some reports
      r1 = Report.new()
      r1.description = 'foobar'
      r1.datetime = Date.new(2011,1,1)
      r1.latitude = 2.1
      r1.longitude = 53.1
      r1.zone = Zone.new('http://zoney')
      r1.report_type = ReportType.new('http://reporttype1')
      r1.save!

      r2 = Report.new()
      r2.description = 'bazbar'
      r2.datetime = Date.new(2012,1,1)
      r2.latitude = 2.2
      r2.longitude = 53.1
      r2.zone = Zone.new('http://zoney')
      r2.report_type = ReportType.new('http://reporttype1')
      r2.save!
    end

    it "returns all the reports" do
      Report.all.length.should == 2
    end

  end

  describe "#zone=" do
    it 'sets the associated zone for this report' do
      new_zone = Zone.new('http://zoney')
      subject.zone = new_zone
      subject.zone.should == new_zone
      subject[Report.zone_predicate].first.to_s.should == new_zone.uri.to_s
    end
  end

  describe "#zone" do
    context "when there's an assocated zone" do

      subject do
        r = Report.new
        r.zone = @zone = Zone.new('http://zoney')
        r
      end

      it 'returns the associated zone object' do
        subject.zone.should == @zone
      end
    end

    context "when there's no associated zone" do
      it "returns nil" do
        subject.zone.should be_nil
      end
    end
  end

  describe "#report_type=" do
    it 'sets the associated report type for this report' do
      new_report_type = ReportType.new('http://reporttype1')
      subject.report_type = new_report_type
      subject.report_type.should == new_report_type
      subject[Report.report_type_predicate].first.to_s.should == new_report_type.uri.to_s
    end
  end

  describe "#report_type" do
    context "when there's an assocated report_type" do

      subject do
        r = Report.new
        r.report_type = @report_type = ReportType.new('http://reporttype1')
        r
      end

      it 'returns the associated report type object' do
        subject.report_type.should == @report_type
      end
    end

    context "when there's no associated report_type" do
      it "returns nil" do
        subject.report_type.should be_nil
      end
    end
  end

  describe "#associate_zone" do

    before do
      # make a zone
      z = Zone.new('http://myzone')
      z.label = 'zoneywone'
      z[RDF.type] = Zone.rdf_type
      z.save!
    end

    it 'asisigns zone object based on this reports lat and long' do
      subject.associate_zone
      subject.zone.should_not be_nil
    end
  end



end