class UsersController < ApplicationController
#  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
#  before_filter :correct_user,    only: [:edit, :update]
#  before_filter :admin_user,      only: [:index, :destroy]


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
