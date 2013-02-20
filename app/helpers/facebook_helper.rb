# encoding: UTF-8

module FacebookHelper
  
  def fb_graph
    ftoken = get_token FACEBOOK
    fb_graph  = Koala::Facebook::API.new(ftoken)
  end

  def fb_query_my_admin_pages
    fb_query_my_admin_pages = "SELECT page_id from page_admin where uid=me()"
  end

  def fb_query_page_list(pages_list)
    fb_query_page_list = "SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (#{pages_list})"
  end

  def fb_get_my_admin_pages_info
    fb_get_my_admin_pages_info = fb_graph.fql_query(fb_query_page_list(fb_query_my_admin_pages))
  end

  def fb_get_pages_info(pages_id_list)
    fb_get_pages_info = fb_graph.fql_query(fb_query_page_list(pages_id_list))
  end

  def fb_get_search_pages_list(name)
      search = fb_graph.search("#{name}", {type: 'page'})

      page_ids = []
      search.each do |s|
        page_ids = page_ids + [s["id"]]       
      end 

      fb_get_search_pages_list = page_ids.join(",")   
  end

  
end