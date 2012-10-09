require 'spec_helper'

describe User do

  it 'should set the uri based on the screen name before creating' do
    u = FactoryGirl.create(:user)
    u.uri.should == "http://data.smartjourney.co.uk/id/user/#{u.screen_name}"
  end

  it "should create an rdf user after creation" do
    u = FactoryGirl.create(:user)
    rdf_user = RdfUser.find(u.uri) #shouldn't error
    rdf_user.label.should == u.screen_name
    rdf_user.rdf_type.should == RdfUser.rdf_type
  end

end
