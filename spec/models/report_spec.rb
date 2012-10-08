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

  context 'with a missing created at timestamp' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:created_at].should_not be_empty
      subject.errors[:created_at].should include("can't be blank")
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
      r.latitude = 'blah'
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
      r.longitude = 'bleh'
      r.latitude = 'blah'
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
      # make some reports
      FactoryGirl.create_list(:report, 2)
    end

    it "returns all the reports" do
      Report.all.length.should == 2
    end

  end

  describe "#zone=" do
    it 'sets the associated zone for this report' do
      z = Zone.all.first
      subject.zone = z
      subject.zone.should == z
      subject[Report.zone_predicate].first.to_s.should == z.uri.to_s
    end
  end

  describe "#zone" do
    context "when there's an assocated zone" do

      subject do
        r = Report.new
        r.zone = @zone = Zone.all.first
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

  describe "#associate_zone" do
    it 'asisigns zone object based on this reports lat and long' do
      subject.associate_zone
      subject.zone.should_not be_nil
    end
  end

  describe ".delete_all" do
    it "deletes all reports" do
      FactoryGirl.create(:report)
      Report.all.length.should be > 0
      Report.delete_all
      Report.all.length.should == 0
    end
  end



end