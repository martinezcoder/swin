class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  
  def home
    if signed_in?
      if current_user.pages.count > 0
        session[:active] = { screen: SC_DASHBOARD }
        redirect_to dashboard_path
      else
        redirect_to user_pages_path(current_user)
      end
    end
  end

  def habla
    session[:active] = { screen: SC_PARTICIPA }
  end
end
