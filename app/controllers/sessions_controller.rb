# encoding: UTF-8

class SessionsController < ApplicationController


  def oauth_failure
    flash[:warning] = "Ha rechazado la solicitud."
    redirect_to root_path
  end

  def new
    begin
      @omniauth = request.env["omniauth.auth"]
      if signed_in?
        if auth_exist?
          if same_user?
            turn_on_auth
            redirect_back_or facebook_engage_path
          else
            # this provider is asigned to other user. Posibility of Merge will be done in next version.
            signout_or_merge
            redirect_to facebook_engage_path
          end
        else
          create_new_auth
          turn_on_auth
          redirect_back_or facebook_lists_path
        end
      else
        if auth_exist?
          sign_in(current_auth.user)
          turn_on_auth
          redirect_back_or facebook_engage_path
        else
          @user = User.find_by_email(omniauth['info']['email']) 
          if @user.nil?
            session[:omniauth] = @omniauth
            redirect_to new_user_path
          else
            sign_in(@user)           
            create_new_auth
            turn_on_auth
            redirect_back_or facebook_lists_path
          end

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
