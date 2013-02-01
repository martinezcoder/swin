class UsersController < ApplicationController

  def create
    # no hará falta ya que lo crearé desde authentication
    @user = User.new(params[:user])
    if @user.save
      # Handle a successful save.
      redirect_to @user
    else
      redirect_to root_url
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
end
