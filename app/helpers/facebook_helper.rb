# encoding: UTF-8

module FacebookHelper
  
  def fb_graph
    ftoken = get_token FACEBOOK
    fb_graph  = Koala::Facebook::API.new(ftoken)
  end
  
  def fb_my_admin_id_pages
    my_pages_admin = "SELECT page_id from page_admin where uid=me()"
  end
 
  def fb_page_list_query(page_list)
    page_list_query = "SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (#{page_list})"
  end

        
  def fb_my_admin_pages_info
    fb_my_admin_pages_info = fb_graph.fql_query(fb_page_list_query(fb_my_admin_id_pages))
  end

  
end