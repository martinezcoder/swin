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

      ftoken = get_token FACEBOOK

      fgraph  = Koala::Facebook::API.new(ftoken)
      search = fgraph.search("#{params[:search]}", {type: "page"})
  
      page_ids = []
      search.each do |s|
        page_ids = page_ids + [s["id"]]       
      end 
  
      str = page_ids.join(",")   
  
      query = fb_page_list_query(str)

      fgraph  = Koala::Facebook::API.new(ftoken)
      @listapages = fgraph.fql_query(query)      
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
