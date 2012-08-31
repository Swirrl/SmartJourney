require "spec_helper"

describe Zone do

  it 'has a sensible graph uri by default' do
    subject.graph_uri.should_not be_nil
    subject.graph_uri.should == Zone.graph_uri
  end

  describe ".all" do

    it "returns all the zones" do
      Zone.all.length.should == 1
    end

  end

  describe "#reports" do

    before do

      r1 = FactoryGirl.create(:report)
      r2 = FactoryGirl.create(:report)
      r3 = FactoryGirl.build(:report)

      z = FactoryGirl.build(:zone)
      z.uri = 'http://zone2'
      z.save!

      r3.zone = z
      z.save!

    end

    it 'returns all the reports for this zone' do
      z = Zone.all.first
      z.reports.length == 2
      z.reports.map(&:class) == [Report, Report]
    end
  end

end