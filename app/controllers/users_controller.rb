class UsersController < ApplicationController

  #Notes: don't need to authorize as can only edit self here!

  def update_zones

    zone_uris = params[:zones].collect { |z_slug, val| Zone.uri_from_slug(z_slug) if val=="1" }

    current_user.zone_uris = zone_uris

    if current_user.save
      flash[:notice] = 'Succesfully updated zones'
      redirect_to edit_user_registration_path
    else
      render edit_user_registration_path
    end

  end

end