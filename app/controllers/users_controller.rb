# encoding: UTF-8

class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user
  before_filter :not_aproved_user, only: [:destroy]

  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if !@user.approved_policy
      if @user.update_attributes(params[:user])
#      @user.approved_policy = params[:user][:approved_policy]
#      @user.name = params[:user][:name]
#      @user.save!
        sign_in(@user)
        flash[:error] = 'No ha aceptado las condiciones de registro' unless current_user.approved_policy
      else
        flash[:error] = @user.errors.full_messages
      end
    end
    redirect_to root_path
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:info] = "Registro cancelado."
    redirect_to root_path
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def not_aproved_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless !@user.approved_policy
    end

end
