class SiteController < ApplicationController
  
  layout "site"
  
  def home 
      @pages = Page.count
      @users = User.count
      
      kk = FbMetrics.new()
      @top_engage = FbTopEngage.where("day = ?", Time.now.yesterday.strftime("%Y%m%d").to_i)
      @top_engage.each do |p|
        p.engagement = kk.get_engagement(p.fan_count, p.talking_about_count)
      end
  end

  def search_page
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