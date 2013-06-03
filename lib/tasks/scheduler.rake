namespace :db do

  desc "Updating free acounts..."
  task update_feed: :environment do
    puts "Updating free acounts..."
        puts Time.now
        batch_facebook_multiquery
        puts Time.now 
    puts "done."
  end

  desc "Updating membership acounts..."
  task premium: :environment do
      puts Time.now
      populate_page_stream
      puts Time.now
      batch_facebook_multiquery
      puts Time.now 
  end

  task :send_reminders => :environment do
#    User.send_status_reports
  end



  def time_diff(start, finish)
     return (finish - start)
  end  

  def update_page_data(p)
      dayYesterday = Time.now.yesterday.strftime("%Y%m%d").to_i

      page = Page.find_by_page_id(p["page_id"].to_s)
      pagedata = PageDataDay.find_or_initialize_by_page_id_and_day(page.id, dayYesterday)     
      pagedata.likes = p["fan_count"]
      pagedata.prosumers = p["talking_about_count"]

      pagedata.comments = page.page_streams.where("day = #{dayYesterday}").sum("comments_count")
      pagedata.shared = page.page_streams.where("day = #{dayYesterday}").sum("share_count")
      pagedata.total_likes_stream = page.page_streams.where("day = #{dayYesterday}").sum("likes_count")
      pagedata.posts = page.page_streams.where("day = #{dayYesterday}").count

      pagedata.save!
      
      page.fan_count = p["fan_count"]
      page.talking_about_count = p["talking_about_count"]
      page.save!
  end


  def batch_facebook_multiquery
    me = User.find_by_id(1)
    ftoken = me.authentications.find_by_provider("facebook").token
    @api = Koala::Facebook::API.new(ftoken) 

    t1 = Time.now

    #best
    #    maxPages = 50
    #    maxBatch = 15
    #    maxMultiQueries = 7

    maxPages = 48 # maximum limited by Facebook = 50
    maxBatch = 15 # maximum limited by Facebook = 50
    maxMultiQueries = 7 # maximum limited by Facebook = 50

    indexPages = 0
    pages = Page.all
    while indexPages < Page.count do

      # Start Batch process
      response = @api.batch do |batch_api|

          pages = Page.limit(maxPages).offset(indexPages).order('id')

          nBatch = 0
          while !pages.empty? and (nBatch < maxBatch) do

              qhash = {}
              (0..maxMultiQueries-1).each do |q|
                  id_list = []
                  pages.each do |p|
                    id_list = id_list + [p.page_id]
                  end
                  id_list = id_list.join(",")
    
                  qhash["query"+q.to_s] = "SELECT page_id, fan_count, talking_about_count from page WHERE page_id in (#{id_list})"

                  indexPages += pages.count
                  puts Time.now.to_s + ": Pages from " + pages[0].id.to_s + " to " + pages[pages.count-1].id.to_s 

                  pages = Page.limit(maxPages).offset(indexPages).order('id')
                  break if (pages.count == 0)

              end

              batch_api.fql_multiquery(qhash)
              nBatch += 1
          end

      @ta=Time.now
      end
      # End Batch process
      tb = Time.now

      puts Time.now.to_s + ": Facebook response: " + time_diff(@ta, tb).to_s + " seconds."

      puts Time.now.to_s + ": Updating pages..." 
      (0..response.length-1).each do |nResp|
        (0..response[nResp].length-1).each do |nQuery|
          (0..response[nResp][nQuery]["fql_result_set"].length-1).each do |nPage|
            update_page_data(response[nResp][nQuery]["fql_result_set"][nPage])
          end
        end
      end

    end

    t2 = Time.now
    puts Time.now.to_s + ": Processed in: " + time_diff(t1, t2).to_s + " seconds." 
    
  end



###########################

  def update_page_stream(page_id, page_st)
    begin
      if !page_st["permalink"].nil? and !page_st["permalink"].empty? 
        stream = PageStream.find_or_initialize_by_page_id_and_created_time(page_id, page_st["created_time"])
        stream.post_id = page_st["post_id"]
        stream.permalink = page_st["permalink"]
        if !page_st["attachment"]["media"].nil? 
          if !page_st["attachment"]["media"][0].nil?
            stream.media_type = page_st["attachment"]["media"][0]["type"]
          end
        end 
        stream.actor_id = page_st["actor_id"]
        stream.target_id = page_st["target_id"]
        stream.likes_count = page_st["likes"]["count"]
        stream.comments_count = page_st["comment_info"]["count"]
        stream.share_count = page_st["share_count"] 
        stream.created_time = page_st["created_time"]
        stream.day = Time.now.yesterday.strftime("%Y%m%d").to_i
        stream.save!
      end
    rescue => error
      puts error.backtrace
      puts page_st
    end
  end




  def populate_page_stream
    me = User.find_by_email("francisjavier@gmail.com")
    ftoken = me.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)
    
    time_from = Time.now.yesterday.yesterday.end_of_day.to_i
    time_to   = Time.now.yesterday.end_of_day.to_i

    Page.all.sort.each do |p|
      n = 0
      m = 50    

      end_loop = false
      while !end_loop do
        query =  "SELECT post_id, permalink, likes, actor_id, target_id, attachment, comment_info, share_count, created_time FROM stream WHERE source_id = #{p.page_id} and updated_time > #{time_from} and updated_time <= #{time_to} LIMIT #{n},#{m}"
        fbstream = fgraph.fql_query(query)

        if fbstream.empty?
          # when a page doesn't have any stream in these range of data
          end_loop = true
        else
          for i in 0..fbstream.count-1 #m-1
            if fbstream[i].nil?
              # last hash post when less than m posts
              break
            else
              update_page_stream(p.id, fbstream[i])  
            end
          end
        end

        n = m
        m = n+50
      end
    end
  end

end