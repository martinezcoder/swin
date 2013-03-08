class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      redirect_to dashboard_main_path
    end
  end

end
