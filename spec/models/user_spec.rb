require 'spec_helper'

describe User do

  it 'should set the uri based on the screen name on save' do
    u = User.new
    u.screen_name = 'foobar'
    u.email = 'Ric@swirrl.com'
    u.password = 'foobar'
    u.save.should == true

    u.uri.should == "http://#{PublishMyData.local_domain}/id/users/#{u.screen_name}"


  end

end
