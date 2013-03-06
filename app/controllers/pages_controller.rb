class PagesController < ApplicationController
  include PagesHelper

  before_filter :signed_in_user
  before_filter :correct_user, except: [:search]
  before_filter :correct_user_page, only: [:competitors, :activate]
  before_filter :has_pages, except: [:index] #, only: [:search]

  def index
    if params[:update] == 'yes'
      pages_update_from_facebook
    end
    @user = User.find(params[:user_id])
    @pages = @user.pages

    if (@pages.count > 0) 
      if ss_active_page.nil?
        @user.pages.first.activate_user_page(@user) 
      end
        @page = @user.pages.find(ss_active_page)
        @competitors = @page.competitors

    end
  end

  def search
    @user = current_user
    @page = @user.pages.find(ss_active_page)
    @competitors = @page.competitors
    fb_list = nil
    if params.has_key?(:search) && params[:search] != ""
      pages_ids_list = fb_get_search_pages_list(params[:search])      
      fb_list = fb_get_pages_info(pages_ids_list)
      @pageslist = []
      fb_list.each do |p|
        page = Page.new
        page.page_id             = p["page_id"]
        page.pic_square          = p["pic_square"]
        page.name                = p["name"]
        page.page_url            = p["page_url"]
        page.page_type           = p["type"]
        page.username            = p["username"]
        page.fan_count           = p["fan_count"]
        page.talking_about_count = p["talking_about_count"]
        @pageslist = @pageslist + [page]
      end
    end
  end

  def competitors
    @title = "Competidores"
    @page = Page.find(params[:id])
    @competitors = @page.competitors.order("created_at DESC")
    render 'show_competitors'
  end  

  def activate
    Page.find(params[:id]).activate_user_page(current_user)
    redirect_to user_pages_path(current_user)
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

    def correct_user_page
      begin
        @page1 = Page.find(params[:id])
        @page2 = current_user.pages.find_by_id(params[:id])
        redirect_to user_pages_path(current_user) unless (@page1 == @page2)
      rescue
        redirect_to user_pages_path(current_user) 
      end
    end

    def has_pages
      begin
        @pages = current_user.pages
        redirect_to root_path unless (@pages.count > 0)
      rescue
        redirect_to root_path
      end 
    end

end
