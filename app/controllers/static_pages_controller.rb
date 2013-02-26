class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      @page = current_user.pages.find_by_id(ss_active_page)
    end
  end

  def help
  end


  def about
  end

end
