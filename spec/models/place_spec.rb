require "spec_helper"

describe Place do

  context 'with a missing latitude' do

    it 'is invalid' do
      subject.should_not be_valid
      subject.errors[:latitude].should_not be_empty
      subject.errors[:latitude].should include("can't be blank")
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
      r = Place.new()
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
      r = Place.new()
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

  describe "#zone=" do
    it 'sets the associated zone for this report' do
      z = Zone.all.first
      subject.zone = z
      subject.zone.should == z
      subject[Place.zone_predicate].first.to_s.should == z.uri.to_s
    end
  end

  describe "#zone" do
    context "when there's an assocated zone" do

      subject do
        p = Place.new
        p.zone = @zone = Zone.all.first
        p
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

  describe "#associate_zone" do
    it 'asisigns zone object based on this places lat and long' do
      subject.associate_zone
      subject.zone.should_not be_nil
    end
  end

end

