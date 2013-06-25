namespace :db do
  
  task fb_top_engage: :environment do
    puts "Calculating top engagement..."
        puts Time.now
        fb_top_engage
        puts Time.now 
    puts "done."
  end

  def fb_top_engage
    day_yesterday = Time.now.yesterday.strftime("%Y%m%d").to_i

    topPagesYesterday = PageDataDay.select("page_id, likes, prosumers, ((prosumers*100)/likes)*6").where("day = ? and likes > 100000", day_yesterday).order('2 DESC').limit(3)

    begin
      topPagesYesterday.each do |p|
        topEngage = FbTopEngage.new()
        topEngage.day                 = day_yesterday
        topEngage.page_id             = p.page_id
        topEngage.fan_count           = p.likes
        topEngage.talking_about_count = p.prosumers
        topEngage.page_fb_id          = Page.find_by_id(p.page_id).page_id
        topEngage.variation = 0    
        topEngage.save! 
      end
    rescue
      puts "Probable duplicate key"
    end

  end
end