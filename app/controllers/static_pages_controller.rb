class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  
  def home
    if signed_in?
      if current_user.pages.count > 0
        redirect_to dashboard_path
      else
        redirect_to user_pages_path(current_user)
      end
    end
  end

  def habla
    session[:active] = { tab: FACEBOOK, opt: OPT_HABLA }
  end
end
