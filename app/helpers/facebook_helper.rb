# encoding: UTF-8

module FacebookHelper

  class FbGraphAPI < Koala::Facebook::API

      def get_my_admin_pages_info
        fql_query(query_page_list(query_my_admin_pages))
      end
  
      def get_pages_info(pages_id_list)
        fql_query(query_page_list(pages_id_list))
      end
      alias_method :get_page_info, :get_pages_info
  
      def get_search_pages_info(name)
        get_pages_info(get_search_pages_list(name))
      end
  
      def get_page_stream(p_id)
        time_from = Time.now.yesterday.yesterday.end_of_day.to_i
        time_to   = Time.now.yesterday.end_of_day.to_i  
        n = 0
        m = 50    
        t = time_from +1
        all_stream = []
        end_loop = false
        while !end_loop do
          fb_stream = @fb_graph.fql_query(query_page_stream(p_id, time_from, time_to, n, m))
          if fb_stream.empty?
            # when a page doesn't have any stream in these range of data
            end_loop = true
          else
            all_stream += fb_stream
          end
          n = m
          m = n+50
        end
        get_page_stream = all_stream
      end
  
  
    protected
  
      def query_my_admin_pages
        "SELECT page_id from page_admin where uid=me()"
      end
  
      def query_page_list(pages_list)
        "SELECT page_id, type, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (#{pages_list})"
      end
  
      def query_page_stream(p_id, time_from, time_to, n, m)
        "SELECT post_id, permalink, likes, actor_id, target_id, attachment, comments, share_count, created_time FROM stream WHERE source_id = #{p_id} and created_time > #{time_from} and created_time < #{time_to} LIMIT #{n},#{m}"
      end

      def get_search_pages_list(name)
        search_results = search("#{name}", {type: 'page', access_token: access_token})
        page_ids = []
        search_results.each do |s|
          page_ids = page_ids + [s["id"]]
        end 
        return page_ids.join(",")   
      end

  end

 
end