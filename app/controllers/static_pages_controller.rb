class StaticPagesController < ApplicationController
  
  def home
  end

  def help

    @listapages = nil
    if params[:q]
      ftoken = current_user.authentications.find_by_provider(FACEBOOK).token
      
      fgraph  = Koala::Facebook::API.new(ftoken)
  
      search = fgraph.search("#{params[:q]}", {type: "page"})
  
      page_ids = []
      search.each do |s|
        page_ids = page_ids + [s["id"]]       
      end 
  
      str = page_ids.join(",")   
  
      query = "SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count, were_here_count from page WHERE page_id in (#{str})"
      fgraph  = Koala::Facebook::API.new(ftoken)
      @listapages = fgraph.fql_query(query)      
    end


  end

  def about
  end

end
