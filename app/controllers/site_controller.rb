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
          @fb_search_path = nil
          if params[:search].include?("https://www.facebook.com")
              subUrl = params[:search].split('/').last.split('?').first
              subUrl = subUrl + '?fields=id,name'
              @fb_search_path = "https://graph.facebook.com/" + subUrl
          else
              me = User.find_by_id(1)
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

  
end