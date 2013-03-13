class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      redirect_to dashboard_path(tab: FACEBOOK, opt:FANS_OPT)
    end
  end

end
