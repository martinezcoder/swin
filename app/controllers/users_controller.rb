# encoding: UTF-8

class UsersController < ApplicationController
#  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
#  before_filter :correct_user,    only: [:edit, :update]
#  before_filter :admin_user,      only: [:index, :destroy]

  before_filter :signed_in_user
  before_filter :correct_user

  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if !@user.approved_policy
      @user.approved_policy = params[:user][:approved_policy]
      @user.save!
      sign_in(@user)
      flash[:error] = 'No ha aceptado las condiciones de registro' unless current_user.approved_policy
    end
    redirect_to root_path
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end
