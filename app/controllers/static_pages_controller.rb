class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      pages_update_from_facebook
      redirect_to dashboard_path(tab: FACEBOOK, opt:DEFAULT_OPT)
    end
  end

end
