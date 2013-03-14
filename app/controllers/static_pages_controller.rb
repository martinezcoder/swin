class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      session[:active] = { screen: SC_DASHBOARD }
      redirect_to dashboard_path
    end
  end

end
