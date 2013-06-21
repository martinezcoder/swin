namespace :db do
  
  task fb_top_engagement: :environment do
    puts "Calculating top engagement..."
        puts Time.now
        fb_top_engagement
        puts Time.now 
    puts "done."
  end

  def fb_top_engagement
    day_yesterday = Time.now.yesterday.strftime("%Y%m%d").to_i

    topPagesYesterday = PageDataDay.select("page_id, likes, prosumers, ((prosumers*6)/likes)").where("day = ? and likes > 100000", day_yesterday).order('2 DESC').limit(3)

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

  end
end