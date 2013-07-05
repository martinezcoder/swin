namespace :dev do

  desc "Fill database with sample data"
  task sample_populate: :environment do
    make_users
    make_authentications
    make_pages
    make_page_relationships
  end

  desc "Fill database with sample data"
  task update_pages_info: :environment do
    puts "start"
    update_pages_info
    puts "done."
  end

  desc "Batch facebook"
  task batch_facebook: :environment do
    puts "start"
    batch_facebook
    puts "done."
  end

  desc "Batch facebook query"
  task batch_facebook_query: :environment do
    puts "start"
    batch_facebook_query
    puts "done."
  end

  desc "Batch facebook multiquery"
  task batch_facebook_multiquery: :environment do
    puts Time.now.to_s + ": start"
    batch_facebook_multiquery
    puts Time.now.to_s + ": done."
  end

  
  def update_pages_info
    userme = User.find_by_email("francisjavier@gmail.com")
    ftoken = userme.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)
    @pages = Page.all
          
    @pages.each do |q|

        puts "SELECT xxx from page WHERE page_id = #{q.page_id}"

        r = fgraph.fql_query("SELECT page_id, type, name, fan_count, talking_about_count from page WHERE page_id = #{q.page_id}")
        p = r[0]

        puts p["page_id"]

        npage = Page.find_by_page_id("#{p["page_id"]}")

        npage.name = p["name"]
        npage.page_type = p["type"]
        npage.fan_count = p["fan_count"]
        npage.talking_about_count = p["talking_about_count"]
        npage.save!
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
    @pages = fgraph.fql_query("SELECT page_id, type, name, fan_count, talking_about_count from page WHERE page_id in (SELECT page_id from page_admin where uid=me())")

    @pages.each do |p|
        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")
        newpage.name = p["name"]
        newpage.page_type = p["type"]
        newpage.save!
    end
 
    50.times do |n|
      page_id = "#{n}"     
      name  = Faker::Name.name

      newpage = Page.new
      newpage.page_id = page_id
      newpage.name = name
      newpage.page_type = @pages.first["type"]
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

  def batch_facebook_query
    me = User.find_by_id(1)
    ftoken = me.authentications.find_by_provider("facebook").token
    @api = Koala::Facebook::API.new(ftoken) 

    t1 = Time.now

    m = 50
    q = 0
    while q < Page.count do
      n = 0

      # Start Batch process
      response = @api.batch do |batch_api|

          pages = Page.limit(m).offset(n)

          while !pages.empty? and (n < m*m) do

              id_list = []
              pages.each do |p|
                id_list = id_list + [p.page_id]
              end
              id_list = id_list.join(",")

              batch_api.fql_query("SELECT page_id, fan_count, talking_about_count from page WHERE page_id in (#{id_list})")

              n = n+pages.count
              pages = Page.limit(m).offset(n)

          end

      @ta=Time.now
      end
      # End Batch process
      tb = Time.now
      puts time_diff @ta, tb

      # End Batch process

      dayYesterday = Time.now.yesterday.strftime("%Y%m%d").to_i

      response.length.times do |i|

          response[i].each do |p|
      
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
      end    

      q = q+n
    end

    t2 = Time.now    
    puts time_diff t1, t2
    
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

    maxPages = 50 # maximum limited by Facebook = 50
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



  def batch_facebook
    me = User.find_by_email("fran.martinez@socialwin.es")
    ftoken = me.authentications.find_by_provider("facebook").token
    @api = Koala::Facebook::API.new(ftoken) 
    
#Page.limit(5).offset(0).order('id')
#Page.limit(5).offset(5).order('id')      
#Page.limit(5).offset(10).order('id')    

#    response = @api.batch do |batch_api|
#      batch_api.get_object('me')
#      batch_api.get_connections('me', 'friends')
#      batch_api.fql_query("SELECT page_id from page_admin where uid=me()")      

=begin
      pages = Page.all
      p = pages[5].page_id
      batch_api.get_object(p, :fields => "likes, talking_about_count")  
=end

=begin
      50.times do |p|
        batch_api.fql_query("SELECT page_id from page_admin where uid=me()")      
      end
=end

=begin
      50.times do |p|
        batch_api.fql_multiquery({
          "query1" => "select post_id from stream where source_id = me()",
          "query2" => "select fromid from comment where post_id in (select post_id from #query1)"
        })
      end
=end

#    end

#    puts response


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


  
end
