class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  
  def home
    if signed_in?
      redirect_to facebook_engage_path
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
