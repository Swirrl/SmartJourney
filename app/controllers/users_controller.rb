class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for signing up"
      sign_in(resource_name, resource)
      redirect_to :root
    else
      render :new
    end
  end

  def edit

  end

  def update

  end

end