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
            data_ini = Time.strptime(params[:from], "%Y%m%d")
            data_fin = Time.strptime(params[:to], "%Y%m%d")
        rescue
          raise noValidDateFormat 
        end
        
        dateRange = (data_fin - data_ini)/60/60/24
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

      if !(page = get_active_list_page)
        list = get_active_list
        page = list.pages.first
        list.set_lider_page(page)
      end

      timeline = PageMetrics.new(page, get_token(FACEBOOK))
      timelineData = timeline.get_timeline_array(params[:from], params[:to])
      @error = timelineData[0]
      @dataA = timelineData[1]
      @dataB = timelineData[2]
      @max = timeline.max
  
    end

  end



  def timeline_engage
    session[:active_tab] = FACEBOOK
        
    if !(page = get_active_list_page)
      list = get_active_list
      page = list.pages.first
      list.set_lider_page(page)
    end

    timeline = PagesHelper::PageMetrics.new(page, get_token(FACEBOOK))
    timelineData = timeline.get_timeline_array(15.days.ago.strftime("%Y%m%d"), Time.now.strftime("%Y%m%d"))
    @error = timelineData[0]
    @dataA = timelineData[1]
    @dataB = timelineData[2]
    @max = timeline.max

    @var = timeline.get_variation(8.days.ago.strftime("%Y%m%d"), 1.days.ago.strftime("%Y%m%d") )
      
  end
  
  def empty
    session[:active_tab] = FACEBOOK
    @list = get_active_list
    @num_competitors = @list.pages.count
  end


  def engage
    session[:active_tab] = FACEBOOK
    
    @list = get_active_list    
    day = Time.now - (24*60*60) # yesterday
    
    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK))
    
    engageData = fb_metric.get_list_engagement_day(@list.pages, day)    
    
    @dataA = engageData[0]
    @dataB = engageData[1]
    @max = fb_metric.max_value

    @options = "seriesType: 'bars', 
                title:'Engagement Hoy (fidelidad de los seguidores)',
                titleTextStyle: {fontSize: 14},
                colors: ['#0088CC'],
                height: 200,
                animation:{duration: 1500,easing: 'out'},
                hAxes:[{title:'Competidores'}],
                vAxis: {minValue:0, maxValue:" + @max.to_s + "},
                fontSize: 10,
                legend: {position: 'none', textStyle: {fontSize: 14}},
                tooltip: {isHtml: true}
                "
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
      fb_pages_info_list = FacebookHelper::FbGraphAPI.new(get_token(FACEBOOK)).get_pages_info(page_ids.join(","))
      pages_create_or_update(fb_pages_info_list)
    end

    css1 = 'mini_logo'
    css2 = 'normal_logo'

    @max_fans = 0
    @max_actives = 0

    num = competitors.length
    compList = []
    htmls = DashboardHelper::HtmlHardcodes.new()
    for i in 0..num-1 do
      compList[i] = [ htmls.logo(get_url(competitors[i]), get_picture(competitors[i]), competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      competitors[i].fan_count,
                      competitors[i].talking_about_count,
                      htmls.logo(get_url(competitors[i]), get_picture(competitors[i]), competitors[i].name, css2),
                      htmls.html_tooltip_general(get_picture(competitors[i]), competitors[i].name, competitors[i].fan_count, competitors[i].talking_about_count)]
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
