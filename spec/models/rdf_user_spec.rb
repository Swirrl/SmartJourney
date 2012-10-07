require "spec_helper"

describe RdfUser do

  describe ".delete_all" do
    it "deletes all users in the triple store" do
      u = FactoryGirl.create(:user)
      RdfUser.find(u.uri) #shouldn't error
      RdfUser.delete_all
      # should error now - not there.
      lambda {rdf_user = RdfUser.find(u.uri) }.should raise_error(Tripod::Errors::ResourceNotFound)
    end
  end

end