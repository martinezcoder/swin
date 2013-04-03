namespace :db do

  desc "Updating free acounts..."
  task update_feed: :environment do
    puts "Updating free acounts..."
        puts Time.now
        populate_page_data
        puts Time.now 
    puts "done."
  end

  desc "Updating membership acounts..."
  task premium: :environment do
      puts Time.now
      populate_page_stream
      puts Time.now
      populate_page_data
      puts Time.now 
  end

  task :send_reminders => :environment do
#    User.send_status_reports
  end



  def populate_page_data
    # Groups of nblock pages:    
    nblock = 30
    nmax = Page.count
    n = 1
    while n < nmax do  
        if nmax-n < nblock
          nnext = nmax
        else
          nnext = n + nblock
        end
        id_list = []
        Page.where("id between ? and ?", n, nnext).each do |p|
          id_list = id_list + [p.page_id]
        end
        id_list = id_list.join(",")
        fb_list_pages_update(id_list)
        puts "Page.id from #{n} to #{nnext} terminated"
        n = nnext+1
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
        query =  "SELECT post_id, permalink, likes, actor_id, target_id, attachment, comments, share_count, created_time FROM stream WHERE source_id = #{p.page_id} and updated_time > #{time_from} and updated_time <= #{time_to} LIMIT #{n},#{m}"
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

  def fb_list_pages_update(page_id_list)
    yesterday = Time.now.yesterday.strftime("%Y%m%d").to_i
    me = User.find_by_email("francisjavier@gmail.com")
    ftoken = me.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)
    fbpages = fgraph.fql_query("SELECT page_id, fan_count, talking_about_count from page WHERE page_id in (#{page_id_list})")
    fbpages.each do |p|
      page = Page.find_by_page_id(p["page_id"].to_s)
      pagedata = PageDataDay.find_or_initialize_by_page_id_and_day(page.id, yesterday)     
      pagedata.likes = p["fan_count"]
      pagedata.prosumers = p["talking_about_count"]

      pagedata.comments = page.page_streams.where("day = #{yesterday}").sum("comments_count")
      pagedata.shared = page.page_streams.where("day = #{yesterday}").sum("share_count")
      pagedata.total_likes_stream = page.page_streams.where("day = #{yesterday}").sum("likes_count")
      pagedata.posts = page.page_streams.where("day = #{yesterday}").count
      pagedata.day = yesterday
      pagedata.save!
      
      page.fan_count = p["fan_count"]
      page.talking_about_count = p["talking_about_count"]
      page.save!
    end
  end

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
        stream.comments_count = page_st["comments"]["count"]
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

end