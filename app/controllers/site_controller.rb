class SiteController < ApplicationController
  
  layout "site"
  
  def home 
      @pages = Page.count
      @users = User.count
      
      metrics = FbMetrics.new()
      top_engage_list = FbTopEngage.where("day = ?", Time.now.yesterday.strftime("%Y%m%d").to_i)
      top_engage_list.each do |tops|
        tops.engagement = metrics.get_engagement(tops.fan_count, tops.talking_about_count)
      end

      @top_engage = top_engage_list.sort_by{|data| data.engagement}.reverse

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