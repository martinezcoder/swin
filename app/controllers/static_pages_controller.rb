class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      if ss_active_page == "0"
        redirect_to pages_index_path
      else
        @page = current_user.pages.find_by_id(ss_active_page)
      end
    end
  end

  def help
  end


  def about
  end

end
