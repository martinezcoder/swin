namespace :db do
  
  task broken_day: :environment do
    unless ENV.include?("day")
      raise "usage: rake db:broken_day day= # valid formats are dates with mask YYYYMMDD" 
    end
    repare_day(ENV['day'])
  end

  task delete_broken_data_days: :environment do
    delete_broken_data_days
  end

  def delete_broken_data_days
    days = PageDataDay.where("day > ?", 99999999)
    days.each do |d|
      d.destroy
    end
    stream = PageStream.all
    stream.each do |s|
      s.destroy
    end
  end

  def repare_day(day)
    day_before = day.to_time.yesterday.strftime("%Y%m%d").to_i
    puts "day_before: #{day_before}"
    day_after =  day.to_time.tomorrow.strftime("%Y%m%d").to_i
    puts "day_after: #{day_after}"
    
    pages = Page.all
    
    pages.each do |p|
      
      print "Page[#{p.id}]. "
      
      pdata_before = PageDataDay.find_by_page_id_and_day(p.id, day_before)
      pdata_after = PageDataDay.find_by_page_id_and_day(p.id, day_after)
      
      if !pdata_before.nil? and !pdata_after.nil?
        plikes = (pdata_before.likes + pdata_after.likes) / 2
        pprosumers = (pdata_before.prosumers + pdata_after.prosumers) / 2
        
        pdata = PageDataDay.find_or_initialize_by_page_id_and_day(p.id, day)     
        pdata.likes = plikes
        pdata.prosumers = pprosumers
  
        pdata.comments = 0
        pdata.shared = 0
        pdata.total_likes_stream = 0
        pdata.posts = 0
  
        pdata.save!
        
        puts "page #{p.id} saved with #{plikes} likes and #{pprosumers} prosumers."
      else
        puts "page #{p.id} with empty data"
      end

    end

  end

end