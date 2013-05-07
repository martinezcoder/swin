class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  
  def home
    if signed_in?
      if current_user.pages.count > 0
        redirect_to dashboard_engage_path
      else
        redirect_to user_pages_path(current_user)
      end
    else
      @pages = Page.count
      @users = User.count
    end
  end

  def habla
    session[:active] = { tab: FACEBOOK, opt: OPT_HABLA }
    @page = current_user.pages.find_by_id(get_active_page)
  end

  def twitter
    session[:active] = { tab: TWITTER, opt: nil }
    @page = current_user.pages.find_by_id(get_active_page)
  end

  def youtube
    session[:active] = { tab: YOUTUBE, opt: nil }
    @page = current_user.pages.find_by_id(get_active_page)
  end
  
end
