namespace :db do

  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_authentications
    make_pages
    make_page_relationships
  end

  desc "Fill page_data_day table with real data"
  task page_data: :environment do
    populate_page_data
  end

  def populate_page_data
    
    me = User.find_by_email("francisjavier@gmail.com")
    ftoken = me.authentications.find_by_provider("facebook").token
    fgraph  = Koala::Facebook::API.new(ftoken)

    page_ids = []
    Page.all.each do |s|
      page_ids = page_ids + [s.page_id]       
    end 
    page_ids = page_ids.join(",") 

    thispages = fgraph.fql_query("SELECT page_id, fan_count, talking_about_count from page WHERE page_id in (#{page_ids})")

    thispages.each do |p|
      page = Page.find_by_page_id(p["page_id"].to_s)
      pagedata = PageDataDay.find_or_initialize_by_page_id(page.id)     
      pagedata.likes = p["fan_count"]
      pagedata.prosumers = p["talking_about_count"]
      pagedata.save!
    end    

=begin
    Page.all.each do |p|
      pagedata = PageDataDay.find_or_initialize_by_page_id(p.id)
      thispages = fgraph.fql_query("SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (#{p.page_id})")     
      pagedata.likes = thispages.first["fan_count"]
      pagedata.prosumers = thispages.first["talking_about_count"]
      pagedata.save!
    end    
=end

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