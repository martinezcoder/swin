# encoding: UTF-8

class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user
  before_filter :approved_user, only: [:show]
  before_filter :not_approved_user, only: [:destroy]


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
        sign_in(@user)
        if current_user.approved_policy
          flash[:info] = 'Bienvenido'
          render 'show'
        else
          flash[:info] = 'No ha aceptado las condiciones de registro'
          render 'edit'
        end
      else
        render 'edit'
      end
    else
      render 'show'
    end
    
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

    def not_approved_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless !@user.approved_policy
    end

    def approved_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless @user.approved_policy
    end

end
