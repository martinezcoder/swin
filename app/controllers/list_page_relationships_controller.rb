class ListPageRelationshipsController < ApplicationController
  before_filter :signed_in_user

  def create
    begin
      list = current_user.facebook_lists.find_by_id(params[:list_page_relationship][:list_id])

      fb_page = FacebookHelper::FbGraphAPI.new(get_token(FACEBOOK)).get_page_info(params[:page_id])    
      page = page_create_or_update(fb_page.first) 
  
      if current_user.facebook_lists.count < MAX_COMPETITORS
        list.add!(page) if !list.added?(page)
        # get today's activity data
        if PageDataDay.find_by_page_id(page.id).nil?
          page_data_day_update(page.id)
        end  
      end
      
      if list.page_id.nil?
        list.set_lider_page(page)
      end

      redirect_to edit_facebook_list_path(list, search: params[:search])
    rescue
      redirect_to facebook_lists_path
    end
  end

  def destroy
    begin
      list = current_user.facebook_lists.find_by_id(cookies[:fb_list])
      page = Page.find(params[:id])
      list.remove!(page)

      if list.pages.any? 
        p = Page.find(list.page_id)
        if !list.added?(p)
          list.set_lider_page(list.pages.first)
        end
      end

      redirect_to edit_facebook_list_path(list, search: params[:search])
    rescue
      redirect_to facebook_lists_path
    end

  end

end