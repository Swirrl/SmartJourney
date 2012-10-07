require "spec_helper"

describe Zone do

  describe ".all" do

    it "returns all the zones" do
      Zone.all.length.should be > 0
    end

  end

  describe "#reports" do

    before do

      r1 = FactoryGirl.create(:report)
      r2 = FactoryGirl.create(:report)
      r3 = FactoryGirl.build(:report)

      r3.zone = Zone.all.first

    end

    it 'returns all the reports for this zone' do
      z = Zone.all.first
      z.reports.length == 2
      z.reports.map(&:class) == [Report, Report]
    end
  end

end