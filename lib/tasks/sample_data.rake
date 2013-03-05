namespace :db do

  desc "Fill database with sample data"
  task sample_populate: :environment do
    make_users
    make_authentications
    make_pages
    make_page_relationships
  end

  desc "Fill daily stream tables"
   task populate: :environment do
      puts Time.now
      populate_page_stream
      puts Time.now
      populate_page_data
      puts Time.now 
  end

  desc "Fill page_data_day table with real data"
  task page_data: :environment do
    populate_page_data
  end

  desc "Fill page_stream table with real data"
  task page_stream: :environment do
    populate_page_stream
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
        stream.day = Time.now.yesterday.beginning_of_day
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
        query =  "SELECT post_id, permalink, likes, actor_id, target_id, attachment, comments, share_count, created_time FROM stream WHERE source_id = #{p.page_id} and created_time > #{time_from} and created_time < #{time_to} LIMIT #{n},#{m}"
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
    me = User.find_by_email("francisjavier@gmail.com")
    ftoken = me.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)
    fbpages = fgraph.fql_query("SELECT page_id, fan_count, talking_about_count from page WHERE page_id in (#{page_id_list})")
    fbpages.each do |p|
      page = Page.find_by_page_id(p["page_id"].to_s)
      pagedata = PageDataDay.find_or_initialize_by_page_id_and_day(page.id, Time.now.yesterday.beginning_of_day.to_i)     
      pagedata.likes = p["fan_count"]
      pagedata.prosumers = p["talking_about_count"]
      pagedata.comments = page.page_streams.sum("comments_count")
      pagedata.shared = page.page_streams.sum("share_count")
      pagedata.total_likes_stream = page.page_streams.sum("likes_count")
      pagedata.posts = page.page_streams.count
      pagedata.day = Time.now.yesterday.beginning_of_day.to_i
      pagedata.save!  
      page.fan_count = p["fan_count"]
      page.talking_about_count = p["talking_about_count"]
      page.save!
    end
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
        n = nnext+1
    end
  end

  def make_users
    fran1 = User.create!(name: "Fran",
                        email: "francisjavier@gmail.com",
                        terms_of_service: "1")

    fran2 = User.create!(name: "Fran J Martinez",
                        email: "fran.martinez@socialwin.es",
                        terms_of_service: "1")

    20.times do |n|
      name  = Faker::Name.name
      email = Faker::Internet.email
      User.create!(name:     name,
                   email:    email,
                   terms_of_service: "1")
    end

  end

  def make_authentications
    fran1 = User.find_by_email("francisjavier@gmail.com")
    newauth = fran1.authentications.new 
    newauth.provider = "facebook" 
    newauth.uid = "590064085"
    newauth.token = "AAAEElmAmn7cBAHqSqI6dI0WtMvpXnz04bqOwwtupzOxKe3EvYPXtkJIZCYJGcrBSpVBQJR3wZACmbWtbT0gXFlOCqR0fVzwYgZAZCjT24AZDZD"
    newauth.save!
    fran2 = User.find_by_email("fran.martinez@socialwin.es")
    newauth = fran2.authentications.new 
    newauth.provider = "facebook" 
    newauth.uid = "100004750117953"
    newauth.token = "AAAEElmAmn7cBAPZA6iCLGSHxjDLFt9Ye0IzQ33quoNGle5AN7Me4vBiiamvZBvhe12WroeFduEFk1ghx5U5PrdQiMpZCWQNeZBqnNZBPm8wZDZD"
    newauth.save!
  end

  def make_pages
 
    userme = User.find_by_email("francisjavier@gmail.com")
    ftoken = userme.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)
    @pages = fgraph.fql_query("SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (SELECT page_id from page_admin where uid=me())")

    @pages.each do |p|
        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")
        newpage.name = p["name"]
        newpage.username = p["username"]
        newpage.page_type = p["type"]
        newpage.page_url = p["page_url"]
        newpage.pic_square = p["pic_square"]
        newpage.save!
    end
 
    50.times do |n|
      page_id = "#{n}"     
      name  = Faker::Name.name

      newpage = Page.new
      newpage.page_id = page_id
      newpage.name = name
      newpage.username = @pages.first["username"]
      newpage.page_type = @pages.first["type"]
      newpage.page_url = @pages.first["page_url"]
      newpage.pic_square = @pages.first["pic_square"]
      newpage.save!
    end
  end

  def make_page_relationships

    allpages = Page.all
    page  = allpages.first
    competitors = allpages[7..10]
    followers   = allpages[5..20]

    competitors.each { |competitor| page.follow!(competitor) }
    followers.each   { |follower| follower.follow!(page) }

  end

end