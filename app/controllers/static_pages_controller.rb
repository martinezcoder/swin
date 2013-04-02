class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  before_filter :has_active_page, only: :habla
  
  def home
    if signed_in?
      if current_user.pages.count > 0
        redirect_to dashboard_path
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


private 

  def has_active_page
    begin
      redirect_to root_path if get_active_page.nil? 
    rescue
      redirect_to root_path
    end 
  end
  
end
