# encoding: UTF-8

module FacebookHelper

  class FacebookResponses < Koala::Facebook::API
    
    attr_reader :admin, :query
    
    def initialize(token)
      
    end

    def fb_query_page_list(pages_list)
      @query = "SELECT page_id, username, type, page_url, name, pic_square, pic_big, fan_count, talking_about_count from page WHERE page_id in (#{pages_list})"
    end

        
  end  
    

  def fb_token
     get_token FACEBOOK
  end
  
  def fb_graph
    fb_graph  = Koala::Facebook::API.new(fb_token)
  end

  def fb_query_my_admin_pages
    fb_query_my_admin_pages = "SELECT page_id from page_admin where uid=me()"
  end

  def fb_query_page_list(pages_list)
    fb_query_page_list = "SELECT page_id, username, type, page_url, name, pic_square, pic_big, fan_count, talking_about_count from page WHERE page_id in (#{pages_list})"
  end

  def fb_query_page_stream(p_id, time_from, time_to, n, m)
    fb_query_page_stream =  "SELECT post_id, permalink, likes, actor_id, target_id, attachment, comments, share_count, created_time FROM stream WHERE source_id = #{p_id} and created_time > #{time_from} and created_time < #{time_to} LIMIT #{n},#{m}"
  end

  def fb_get_my_admin_pages_info
    fb_get_my_admin_pages_info = fb_graph.fql_query(fb_query_page_list(fb_query_my_admin_pages))
  end

  def fb_get_pages_info(pages_id_list)
    fb_get_pages_info = fb_graph.fql_query(fb_query_page_list(pages_id_list))
  end

  def fb_get_search_pages_list(name)
    search = fb_graph.search("#{name}", {type: 'page', access_token: fb_token})

    page_ids = []
    search.each do |s|
      page_ids = page_ids + [s["id"]]
    end 

    fb_get_search_pages_list = page_ids.join(",")   
  end

  def fb_get_page_stream(p_id)
    time_from = Time.now.yesterday.yesterday.end_of_day.to_i
    time_to   = Time.now.yesterday.end_of_day.to_i

    n = 0
    m = 50    
    t = time_from +1

    all_stream = []
    
    end_loop = false
    while !end_loop do

      fb_stream = fb_graph.fql_query(fb_query_page_stream(p_id, time_from, time_to, n, m))


      if fb_stream.empty?
        # when a page doesn't have any stream in these range of data
        end_loop = true
      else
        all_stream += fb_stream
      end

      n = m
      m = n+50
    end

    fb_get_page_stream = all_stream

  end
    
end