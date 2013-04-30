# encoding: UTF-8

class DashboardController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :user_has_pages
  before_filter :has_active_page
  before_filter :has_competitors, except: :empty

  def timeline_engage
    session[:active] = { tab: FACEBOOK, opt: OPT_TIMELINE_ENGAGE }
    @page = current_user.pages.find_by_id(get_active_page)

    nDays = 7
    engageList = []
    
    tToday = Time.now - (nDays*24*60*60)  # nDays ago
    tYesterday = Time.now - ((nDays+1)*24*60*60)  # nDays ago

    engageToday = 0
    engageYesterday = 0
    @max = 0

    dataYesterday = @page.page_data_days.where("day = #{tYesterday.strftime("%Y%m%d").to_i}")
    if !dataYesterday.empty?
      engageYesterday = get_engage(dataYesterday[0].likes, dataYesterday[0].prosumers)
    else
      engageYesterday = 0
    end

    @max = engageYesterday
    
    for i in 0..nDays-1
      dataToday = @page.page_data_days.where("day = #{tToday.strftime("%Y%m%d").to_i}")
      if !dataToday.empty?
        engageToday = get_engage(dataToday[0].likes, dataToday[0].prosumers)
      else
        engageToday = 0
      end
      @max = [@max, engageToday].max
      @var = get_variation(engageToday.to_f, engageYesterday.to_f)
      engageList[i] = [ tToday.strftime("%d/%m/%Y"), # "#{t.year}/#{t.month}/#{t.day}",
                        engageToday,
                        html_tooltip_engage(@page.pic_square, @page.name, engageToday, @var),
                        html_variation(@var),
                        tToday.strftime("%Y%m%d").to_i]
      engageYesterday = engageToday
      tToday = tToday.tomorrow
    end

    engageToday = get_engage(@page.fan_count, @page.talking_about_count)
    @var = get_variation(engageToday.to_f, engageYesterday.to_f)
    engageList[nDays] = [ "Hoy",
                          engageToday,
                          html_tooltip_engage(@page.pic_square, @page.name, engageToday, @var),
                          html_variation(@var),
                          Time.now.strftime("%Y%m%d").to_i]

    @var = get_variation(engageToday.to_f, engageList[0][1]) 

    @dataA = []
    @dataB = []
 
    for i in 0..nDays    
      @dataA[i] = [] + engageList[i]
      @dataA[i][1] = 0
      @dataB[i] = [] + engageList[i]
    end

    @max = 50 if @max <= 50 

  end
  
  def empty
    session[:active] = { tab: FACEBOOK, opt: OPT_NO_COMPETITORS }
    @page = current_user.pages.find_by_id(get_active_page)
    @num_competitors = 0
  end

  def engage
    session[:active] = { tab: FACEBOOK, opt: OPT_ENGAGE }    
    @page = current_user.pages.find_by_id(get_active_page)    

    competitors = []
    competitors[0] = @page
    competitors = competitors + @page.competitors   

    css1 = 'mini_logo'
    css2 = 'normal_logo'

    t = Time.now - (24*60*60) # yesterday
    num = competitors.length
    compList = []
    @max = 0

    for i in 0..num-1 do

      dataDay = competitors[i].page_data_days.where("day = #{t.strftime("%Y%m%d").to_i}")
      if !dataDay.empty?
        engageY = get_engage(dataDay[0].likes, dataDay[0].prosumers)
      else
        engageY = 0
      end

      engage = get_engage(competitors[i].fan_count, competitors[i].talking_about_count)
      variation = get_variation(engage.to_f,engageY.to_f)
      compList[i] = [ logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      engage,
#                      {v: engage, f: '-5.0%'},
                      logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css2),
                      html_tooltip_engage(competitors[i].pic_square, competitors[i].name, engage, variation),
                      html_variation(variation)]

      @max = [@max, engage].max

    end

    compList = compList.sort_by { |a, b, c, d, e, f| d }
    compList = compList.reverse

    @dataA = []
    @dataB = []
 
    for i in 0..compList.length-1 do
      @dataA[i] = [(i+1).to_s] + compList[i]
      @dataA[i][4] = 0
      @dataB[i] = [(i+1).to_s] + compList[i]
    end
    
    @max = 50  if @max <= 50 

  end

  def general
    session[:active] = { tab: FACEBOOK, opt: OPT_GENERAL }
    @page = current_user.pages.find_by_id(get_active_page)

    competitors = []
    competitors[0] = @page
    competitors = competitors + @page.competitors   

    # update only every if last updated was previous than 1 hours ago 
    if @page.updated_at < -1.hour.ago
      # updating competitor data
      page_ids = []
      competitors.each do |p|
        page_ids = page_ids + [p.page_id]
      end 
      page_ids = page_ids + [@page.page_id]
      fb_pages_info_list = fb_get_pages_info(page_ids.join(","))

      pages_create_or_update(fb_pages_info_list)
    end

    css1 = 'mini_logo'
    css2 = 'normal_logo'

    @max_fans = 0
    @max_actives = 0

    num = competitors.length
    compList = []
    for i in 0..num-1 do
      compList[i] = [ logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      competitors[i].fan_count,
                      competitors[i].talking_about_count,
                      logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css2),
                      html_tooltip_general(competitors[i].pic_square, competitors[i].name, competitors[i].fan_count, competitors[i].talking_about_count)]
      @max_fans = [@max_fans, competitors[i].fan_count].max
      @max_actives = [@max_actives, competitors[i].talking_about_count].max
    end

    compList = compList.sort_by { |a, b, c, d, e, f, g| d }
    compList = compList.reverse

    @dataA = []
    @dataB = []

    # nil data for ascendent animation chart 
    for i in 0..compList.length-1 do
      @dataA[i] = [(i+1).to_s] + compList[i]
      @dataA[i][4] = 0
      @dataA[i][5] = 0
      @dataB[i] = [(i+1).to_s] + compList[i]
    end 

  end

private

  def has_active_page
    begin
      redirect_to user_pages_path(current_user) if get_active_page.nil? 
    rescue
      redirect_to user_pages_path(current_user)
    end 
  end

  def has_competitors
    begin
      min_competitors = 1
      page = current_user.pages.find_by_id(get_active_page)
      num_competitors = page.competitors.count
      if num_competitors < min_competitors
        redirect_to dashboard_empty_path
      end
    rescue
      redirect_to dashboard_empty_path
    end
  end

end
