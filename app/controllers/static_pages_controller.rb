class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      pages_update_from_facebook
      redirect_to dashboard_main_path
    end
  end

end
