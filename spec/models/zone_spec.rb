require "spec_helper"

describe Zone do

  it 'has a sensible graph uri by default' do
    subject.graph_uri.should_not be_nil
    subject.graph_uri.should == Zone.graph_uri
  end

  describe ".all" do

    before do
      # make some zones
      z1 = Zone.new('http://zone1')
      z1.label = 'foo'
      z1[RDF.type] = Zone.rdf_type
      z1.save!

      z2 = Zone.new('http://zone2')
      z2.label = 'bar'
      z2[RDF.type] = Zone.rdf_type
      z2.save!
    end

    it "returns all the zones" do
      Zone.all.length.should == 2
    end

  end

  describe "#reports" do

    before do

      @z = Zone.new('http://zone1')
      @z.label = 'foo'
      @z[RDF.type] = Zone.rdf_type
      @z.save!

      r1 = Report.new()
      r1.description = 'foobar'
      r1.datetime = Date.new(2011,1,1)
      r1.latitude = 2.1
      r1.longitude = 53.1
      r1.zone = @z
      r1.report_type = ReportType.new('http://reporttype1')
      r1.save!

      r2 = Report.new()
      r2.description = 'bazbar'
      r2.datetime = Date.new(2012,1,1)
      r2.latitude = 2.2
      r2.longitude = 53.1
      r2.zone = @z
      r2.report_type = ReportType.new('http://reporttype1')
      r2.save!

      r3 = Report.new()
      r3.description = 'bazbar'
      r3.datetime = Date.new(2012,1,1)
      r3.latitude = 2.2
      r3.longitude = 53.1
      r3.zone = Zone.new('http://anotherzone')
      r3.report_type = ReportType.new('http://reporttype1')
      r3.save!

      r1.zone = @z
      r2.zone = @z

    end

    it 'returns all the reports for this zone' do
      @z.reports.length == 2
      @z.reports.map(&:class) == [Report, Report]
    end
  end

end