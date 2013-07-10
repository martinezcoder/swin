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
          @fb_search_path = nil
          if params[:search].include?("https://www.facebook.com")
              subUrl = params[:search].split('/').last.split('?').first
              subUrl = subUrl + '?fields=id,name'
              @fb_search_path = "https://graph.facebook.com/" + subUrl
          else
              me = User.find_by_email("fran.martinez@socialwin.es")
              fb_token = me.authentications.find_by_provider(FACEBOOK).token
              fb_graph = FacebookHelper::FbGraphAPI.new(fb_token)
    
              fb_list = fb_graph.get_search_pages_info(params[:search])
              @pageslist = []
              fb_list.each do |p|
                  page = Page.new
                  page.page_id             = p["page_id"]
                  page.name                = p["name"]
                  @pageslist = @pageslist + [page]
              end
          end
      end    
  end

  
  def about
  end
end