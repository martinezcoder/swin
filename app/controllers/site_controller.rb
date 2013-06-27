class SiteController < ApplicationController
  
  layout "site"
  
  def home 
      @pages = Page.count
      @users = User.count

  end

  def search
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
  
  def about
  end
end