class UsersController < Devise::RegistrationsController

  #Notes: don't need to authorize as can only edit self here!

  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:notice] = 'successfully updated user settings'
      redirect_to edit_user_registration_path
    else
      render "edit"
    end

  end


  def update_zones

    zone_uris = params[:zones].collect { |z_slug, val| Zone.uri_from_slug(z_slug) if val=="1" }
    current_user.zone_uris = zone_uris

    if current_user.save
      flash[:notice] = 'successfully updated zones'
      redirect_to edit_user_registration_path
    else
      render edit_user_registration_path
    end

  end

end