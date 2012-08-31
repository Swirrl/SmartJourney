require "spec_helper"

describe ReportType do

  it 'has a sensible graph uri by default' do
    subject.graph_uri.should_not be_nil
    subject.graph_uri.should == ReportType.graph_uri
  end

  describe ".all" do

    it "returns all the report types" do
      ReportType.all.length.should == 1
    end

  end

end