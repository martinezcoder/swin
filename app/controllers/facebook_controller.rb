# encoding: UTF-8

class FacebookController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :has_active_list
  before_filter :list_has_pages, except: :empty
  before_filter :user_is_admin, only: [:engageX]

  def engageX
    @error = nil
    err = []
    noValidParams        = err[0] = "[{error: parametros no válidos}]"
    noValidDateFormat    = err[1] = "[{error: formato de fecha incorrecto}]"
    noValidDateRange     = err[2] = "[{error: la fecha inicial es posterior a la final}]"
    maxDateRangeExceeded = err[3] = "[{error: el rango de fechas excede el máximo permitido de 3 meses }]"
    noDataFound          = err[4] = "[{error: no hay datos disponibles para las fechas especificadas}]"
    
    session[:active_tab] = FACEBOOK
    
    begin
        if params.has_key?(:from) && params.has_key?(:to) 
          if params[:from] == "" || params[:to] == ""
            raise noValidParams
          end
        else
          raise noValidParams
        end
        
        begin
            @data_ini = Time.strptime(params[:from], "%Y%m%d")
            @data_fin = Time.strptime(params[:to], "%Y%m%d")
        rescue
          raise noValidDateFormat 
        end
        
        dateRange = (@data_fin - @data_ini)/60/60/24
        if dateRange < 0 
          raise noValidDateRange
        end
        if dateRange > MAX_DATE_RANGE
          raise maxDateRangeExceeded
        end
    
    rescue Exception => e
      @error = e.message
    
      respond_to do |format|
        format.html # { redirect_to facebook_path }
        format.json {  render json: @error, status: :unprocessable_entity  }        
      end
    
    else

      if !(@page = get_active_list_page)
        list = get_active_list
        @page = list.pages.first
        list.set_lider_page(@page)
      end

      @dataBD = @page.page_data_days.select("day, likes, prosumers").where("day between ? and ?", params[:from][0,8], params[:to][0,8]).order('day ASC')

      @max = 0
      engageYesterday = 0
      engageList = []
      counter = 0
      
      if @dataBD.count == 0

        @error = noDataFound

      else

        @dataBD.each do |dataDay| 
  
          engageToday = get_engage(dataDay.likes, dataDay.prosumers)
          @max = [@max, engageToday].max
          variation = get_variation(engageToday.to_f, engageYesterday.to_f)
  
          engageList[counter] =  
                            [ Time.strptime(dataDay.day.to_s, "%Y%m%d").strftime("%d/%m/%Y"), 
                            engageToday,
                            html_tooltip_engage(fb_get_picture(@page.page_id), @page.name, engageToday, variation),
                            html_variation(variation),
                            dataDay.day]
          
          engageYesterday = engageToday
          counter += 1
        end
  
        @dataA = []
        @dataB = []
     
        for i in 0..counter-1    
          @dataA[i] = [] + engageList[i]
          @dataA[i][1] = 0
          @dataB[i] = [] + engageList[i]
        end
    
        @max = 50 if @max <= 50 
  
      end
  
    end

  end



  def timeline_engage
    session[:active_tab] = FACEBOOK
        
    if !(@page = get_active_list_page)
      list = get_active_list
      @page = list.pages.first
      list.set_lider_page(@page)
    end

    nDays = 14
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
                        html_tooltip_engage(fb_get_picture(@page.page_id), @page.name, engageToday, @var),
                        html_variation(@var),
                        tToday.strftime("%Y%m%d").to_i]
      engageYesterday = engageToday
      tToday = tToday.tomorrow
    end

    engageToday = get_engage(@page.fan_count, @page.talking_about_count)
    @var = get_variation(engageToday.to_f, engageYesterday.to_f)
    engageList[nDays] = [ "Hoy",
                          engageToday,
                          html_tooltip_engage(fb_get_picture(@page.page_id), @page.name, engageToday, @var),
                          html_variation(@var),
                          Time.now.strftime("%Y%m%d").to_i]
    @max = [@max, engageToday].max
    @var = get_variation(engageToday.to_f, engageList[nDays-7][1]) 

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
    session[:active_tab] = FACEBOOK
    @list = get_active_list
    @num_competitors = @list.pages.count
  end

  def engage
    session[:active_tab] = FACEBOOK    

    @list = get_active_list
    competitors = []
    competitors += @list.pages   

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
      compList[i] = [ logo(fb_get_url(competitors[i].page_id), fb_get_picture(competitors[i].page_id), competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      engage,
#                      {v: engage, f: '-5.0%'},
                      logo(fb_get_url(competitors[i].page_id), fb_get_picture(competitors[i].page_id), competitors[i].name, css2),
                      html_tooltip_engage(fb_get_picture(competitors[i].page_id), competitors[i].name, engage, variation),
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
    session[:active_tab] = FACEBOOK

    @list = get_active_list
    competitors = []
    competitors += @list.pages   

    # update only every page from facebook if last updated was previous than 1 hours ago 
    page = competitors[0]
    if page.updated_at < -1.hour.ago
      # updating competitor data
      page_ids = []
      competitors.each do |p|
        page_ids = page_ids + [p.page_id]
      end 
      page_ids = page_ids + [page.page_id]
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
      compList[i] = [ logo(fb_get_url(competitors[i].page_id), fb_get_picture(competitors[i].page_id), competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      competitors[i].fan_count,
                      competitors[i].talking_about_count,
                      logo(fb_get_url(competitors[i].page_id), fb_get_picture(competitors[i].page_id), competitors[i].name, css2),
                      html_tooltip_general(fb_get_picture(competitors[i].page_id), competitors[i].name, competitors[i].fan_count, competitors[i].talking_about_count)]
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

  def has_active_list
    begin
      redirect_to facebook_lists_path if get_active_list.nil? 
    rescue
      redirect_to facebook_lists_path
    end 
  end

  def list_has_pages
    begin
      min_pages = MIN_COMPETITORS
      list = get_active_list
      num_pages = list.pages.count
      if num_pages < min_pages
        redirect_to facebook_empty_path
      end
    rescue
      redirect_to facebook_empty_path
    end
  end

end
