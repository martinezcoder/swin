# encoding: UTF-8

module PagesHelper
  include FacebookHelper

  def page_engage_chart_tag (height, params = {})
    params[:format] ||= :json
    # jsonPath = query_test_path(params: params)
    jsonPath = page_path(params: params)
    content_tag(:div, :id => 'chart_div2', :'data-chart' => jsonPath, :style => "height: #{height}px;") do
      image_tag('loader.gif', :size => '24x24', :class => 'spinner')
    end
  end
  
  def page_get_picture(page_id, big=nil)
    ret = "https://graph.facebook.com/" + page_id.to_s + "/picture"
    if !big.nil?
      ret += "?type=large"
    end
    return ret
  end

  def page_get_url(page_id)
    ret = "https://www.facebook.com/" + page_id.to_s
    return ret
  end


  def get_engage(fans, actives)
    if fans > 0
      engage = actives * 6 *100 / fans
    else
      engage = 0
    end
    return engage
  end
  
  def get_variation(today, yesterday)
    return ((today - yesterday) / yesterday) * 100
  end

  def page_create_or_update(p, stream=false, daily=false)
        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")

        newpage.name = p["name"]
        newpage.page_type = p["type"]
        newpage.fan_count = p["fan_count"]
        newpage.talking_about_count = p["talking_about_count"]
        newpage.save!
        if stream == UPDATE_STREAM
          page_data_stream_update(page_id)
        end

        if daily == UPDATE_DAY
          page_data_day_update(p_id, data_date=Time.now.beginning_of_day)
        end

        newpage
  end

  def pages_create_or_update(pagelist)
    pagelist.each do |p|
      user_page = page_create_or_update(p)
    end
  end

  def my_admin_pages_update_from_facebook    
    begin
      fbpages = fb_get_my_admin_pages_info
    rescue
      flash[:info] = "Facebook no responde. Por favor, inténtelo más tarde."
      sign_out
      redirect_to root_path
    end
    fbpages.each do |p|
      user_page = page_create_or_update(p)
      current_user.rel_user_page!(Page.find_by_page_id("#{p["page_id"]}"))
    end
  end

  def page_data_day_update(p_id, data_date=Time.now)
      page = Page.find_by_id(p_id)
      pagedata = PageDataDay.find_or_initialize_by_page_id_and_day(page.id, data_date.strftime("%Y%m%d").to_i)     
      pagedata.likes = page.fan_count
      pagedata.prosumers = page.talking_about_count
      pagedata.comments = page.page_streams.sum("comments_count") || 0
      pagedata.shared = page.page_streams.sum("share_count") || 0
      pagedata.total_likes_stream = page.page_streams.sum("likes_count") || 0
      pagedata.posts = page.page_streams.count || 0
      pagedata.day = data_date.to_i
      pagedata.save!
  end



  def page_data_stream_update(page_id)
    fb_page_id = Page.find_by_id(page_id).page_id
    page_stream = fb_get_page_stream(fb_page_id)

    for i in 0..page_stream.count-1
      ps = page_stream[i]
      if !ps["permalink"].nil? and !ps["permalink"].empty? 
        stream = PageStream.find_or_initialize_by_page_id_and_created_time(page_id, ps["created_time"])
        stream.post_id = ps["post_id"]
        stream.permalink = ps["permalink"]
        if !ps["attachment"]["media"].nil? 
          if !ps["attachment"]["media"][0].nil?
            stream.media_type = ps["attachment"]["media"][0]["type"]
          end
        end 
        stream.actor_id = ps["actor_id"]
        stream.target_id = ps["target_id"]
        stream.likes_count = ps["likes"]["count"]
        stream.comments_count = ps["comments"]["count"]
        stream.share_count = ps["share_count"] 
        stream.created_time = ps["created_time"]
        stream.day = Time.now.yesterday.beginning_of_day
        stream.save!
      end
    end
  end

end