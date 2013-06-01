class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  
  def home
    if signed_in?
      if current_user.pages.count > 0
        redirect_to facebook_engage_path
      else
        redirect_to user_pages_path(current_user)
      end
    else
      @pages = Page.count
      @users = User.count
    end
  end

  def habla
    session[:active_tab] = FACEBOOK
  end

  def twitter
    session[:active_tab] = TWITTER
  end

  def youtube
    session[:active_tab] = YOUTUBE
  end
  
end
