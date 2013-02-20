class PagesController < ApplicationController
  include PagesHelper

  before_filter :signed_in_user
  before_filter :correct_user, except: [:search]

  def index
    if params[:update] == 'yes'
      pages_update_from_facebook
    end
    @user = User.find(params[:user_id])
    @pages = @user.pages
  end

  def search
    @listapages = nil
    if params[:search]      
      pages_ids_list = fb_get_search_pages_list(params[:search])      
      @listapages = fb_get_pages_info(pages_ids_list)
    end
  end


  private

    def correct_user
      begin
        @user = User.find(params[:user_id])
        redirect_to user_pages_path(current_user) unless current_user?(@user)
      rescue
        redirect_to user_pages_path(current_user)
      end
    end

end
