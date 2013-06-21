# encoding: UTF-8

class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: [:habla, :admin, :test, :test2, :query_test]
  before_filter :user_is_admin, only: [:admin, :test, :test2, :query_test]
  
  def home
    if signed_in?
      redirect_to facebook_engage_path
    else
      @pages = Page.count
      @users = User.count
      @searching = false

      if params.has_key?(:search) && params[:search] != ""
        @searching = true
        if params[:search].include?("https://www.facebook.com")
          subUrl = params[:search].split('/').last.split('?').first
          subUrl = subUrl + '?fields=id,name'
        else
          subUrl = "search?type=page&q=" + params[:search]
        end
        @fb_search_path = "https://graph.facebook.com/" + subUrl
      end
    end
  end


  def habla
    session[:active_tab] = FACEBOOK
  end

  def twitter
    session[:active_tab] = TWITTER
  end

  def youtube
    session[:active_tab] = YOUTUBE
  end

  def admin
    @ndays = params[:days] || 62
  end  


end
