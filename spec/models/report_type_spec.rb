require "spec_helper"

describe ReportType do

  it 'has a sensible graph uri by default' do
    subject.graph_uri.should_not be_nil
    subject.graph_uri.should == ReportType.graph_uri
  end

  describe ".all" do

    before do
      # make some reportTypes
      t1 = ReportType.new('http://reporttype1')
      t1.label = 'foo'
      t1[RDF.type] = ReportType.rdf_type
      t1.save!

      t2 = ReportType.new('http://reporttype2')
      t2.label = 'foo'
      t2[RDF.type] = ReportType.rdf_type
      t2.save!
    end

    it "returns all the zones" do
      ReportType.all.length.should == 2
    end

  end

end