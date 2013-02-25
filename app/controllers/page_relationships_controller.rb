class PageRelationshipsController < ApplicationController
  include PagesHelper

  before_filter :signed_in_user

  def create    
    mypage = current_user.pages.find(ss_active_page)

    fb_page = fb_get_pages_info(params[:page_id])
    competitor = page_create_or_update(fb_page.first)

    mypage.follow!(competitor)

    respond_to do |format|
      format.html { redirect_to competitors_user_page_path(current_user, mypage) }
      format.js
    end
  end

  def destroy
    mypage = current_user.pages.find(ss_active_page)
    competitor = mypage.competitors.find_by_id(params[:id])

    mypage.unfollow!(competitor)

    respond_to do |format|
      format.html { redirect_to competitors_user_page_path(current_user, mypage) }
      format.js
    end

  end

end