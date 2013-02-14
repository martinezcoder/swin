# encoding: UTF-8

class SessionsController < ApplicationController

  def new
    begin
      @omniauth = request.env["omniauth.auth"]
      if signed_in?
        if auth_exist?
          if same_user?
            turn_on_auth(true)
            redirect_back_or user_path(current_user)
          else
            # this provider is asigned to other user. Posibility of Merge will be done in next version.
            signout_or_merge
            redirect_to root_path
          end
        else
          create_new_auth
          turn_on_auth(true)
          redirect_back_or user_path(current_user)
        end
      else
        if auth_exist?
          sign_in(current_auth.user)
          turn_on_auth(false)
          redirect_back_or user_path(current_user)
        else
          session[:omniauth] = @omniauth
          redirect_to new_user_path
        end
      end
    rescue
        flash[:info] = "Facebook no parece responder. Por favor, inténtelo más tarde."
        sign_out
        redirect_to(root_path)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
