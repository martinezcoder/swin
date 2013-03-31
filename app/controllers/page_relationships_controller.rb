class PageRelationshipsController < ApplicationController
  include PagesHelper

  before_filter :signed_in_user
  before_filter :user_has_pages

  def create    
    mypage = current_user.pages.find(get_active_page)

    if mypage.competitors.count < MAX_COMPETITORS
      fb_page = fb_get_pages_info(params[:page_id])
      competitor = page_create_or_update(fb_page.first)
  
      mypage.follow!(competitor)
  
      #if the page is not registered, then get yesterday's activity data
      if PageDataDay.find_by_page_id(competitor.id).nil?
        page_data_day_update(competitor.id)
      end
      free = true
    else
      free = false
    end
    
    respond_to do |format|
      format.html { redirect_to competitors_user_page_path(current_user, mypage, search: params[:search], free: free) }
      format.js
    end
  end

  def destroy
    mypage = current_user.pages.find(get_active_page)
    competitor = mypage.competitors.find_by_id(params[:id])

    mypage.unfollow!(competitor)

    respond_to do |format|
      format.html { redirect_to competitors_user_page_path(current_user, mypage) }
      format.js
    end

  end

end