# encoding: UTF-8

class UsersController < ApplicationController
#  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
#  before_filter :correct_user,    only: [:edit, :update]
#  before_filter :admin_user,      only: [:index, :destroy]

=begin
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
=end

  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      if params[:user][:policy_checked] == '0'
        flash[:error] = "Acepte las condiciones de uso y política de privacidad." 
        render 'edit'
      else
      # Handle a successful update.
      end
    else
      render 'edit'
    end
  end

end
