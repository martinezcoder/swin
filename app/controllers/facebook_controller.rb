# encoding: UTF-8

class FacebookController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :has_active_list
  before_filter :list_has_pages, except: :empty

  def empty
    session[:active_tab] = FACEBOOK
    @list = get_active_list
    @num_competitors = @list.pages.count
  end

  def engage
    session[:active_tab] = FACEBOOK

    # Tenemos tres opciones de gráficas: 
    # 1 - barras de engagement de un solo día y varios competidores
    # 2 - timeline de engagement de un solo competidor desde/hasta
    # 3 - timeline de engagement de varios competidores desde/hasta
    engage_day       = 0
    engage_timeline  = 1

    @type_graph = nil

    begin
      if !membership_user?
        date_to = Time.now - (24*60*60) # yesterday
        @type_graph = engage_day
      else
        if params.has_key?(:date_from) && params.has_key?(:date_to)
            date_from = Time.strptime(params[:date_from], "%Y%m%d") # historic timeline
            date_to = Time.strptime(params[:date_to], "%Y%m%d")
            dateRange = (date_to - date_from)/60/60/24
            @type_graph = engage_timeline
            if dateRange < 0 
              flash[:info] = "ATENCIÓN: rango de fechas no válido"
              raise
            elsif dateRange > MAX_DATE_RANGE
              flash[:info] = "ATENCIÓN: el rango debe ser inferior a tres meses"
              raise
            elsif date_from == date_to
              @type_graph = engage_day
            end
            
        elsif params.has_key?(:date_to)
            date_to = Time.strptime(params[:date_to], "%Y%m%d") # historic day
        else
            date_to = Time.now - (24*60*60) # yesterday
        end
      end
    rescue
      flash[:info] = "Opps, algo no ha ido bien..." if flash[:info].nil?
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = engage_day
    end

    if @type_graph.nil? 
      @type_graph = engage_day
    end

    # Hasta aquí:
    # @type_graph = engage_timeline ==> Si existe date_from y date_to con fechas diferentes
    # @type_graph = engage_day      ==> en cualquier otro caso

    engage_timeline_single = 2
    engage_timeline_multi  = 3

    @user_list = get_active_list

    if params.has_key?(:pages) && params[:pages] != ""

      list = []
      num_competitors = 0
      @params_pages = params[:pages] 
      @params_pages.each do |p|
        if page = Page.find_by_id(p.to_i)
           if @user_list.pages.include?(page) and !list.include?(page)
             list = list + [page]
             num_competitors += 1
           end 
        end
      end

      if num_competitors > 1
        @type_graph = engage_timeline_multi if @type_graph == engage_timeline
      elsif num_competitors == 1
        if @type_graph == engage_timeline
          @type_graph = engage_timeline_single 
          page = Page.find_by_id(@params_pages[0])
        else
          list = get_active_list.pages
        end
      else
        @type_graph = engage_day
        list = get_active_list.pages # all competitors      
      end

    else
      @type_graph = engage_timeline_multi if @type_graph == engage_timeline 
      list = get_active_list.pages
    end

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 

    case @type_graph
      when engage_day
        engageData = fb_metric.get_list_engagement_day(list, date_to)
      when engage_timeline_single
        engageData = fb_metric.get_page_engagement_timeline(page, date_from, date_to)
      when engage_timeline_multi
        engageData = fb_metric.get_list_engagement_timeline(list, date_from, date_to)
    end

    @errors = fb_metric.error
    if @errors.nil?
      @dataA = engageData[0]
      @dataB = engageData[1]
      #@max = fb_metric.max_value
      @options = fb_metric.options 
    else
      flash[:info] = @errors
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = engage_day
      list = get_active_list.pages # all competitors      
      engageData = fb_metric.get_list_engagement_day(list, date_to)           
    end

  end


  def timeline_engage
    
    session[:active_tab] = FACEBOOK

    @list = get_active_list

    if params.has_key?("page")
      list = []
      @params_page = params["page"]      
      page = Page.find_by_id(@params_page)
    else  
      if !(page = get_active_list_page)
        page = @list.pages.first
        @list.set_lider_page(page)
      end
      params["page"] = page.id.to_s
    end

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK))
    engageData = fb_metric.get_page_engagement_timeline(page, 16.days.ago, 1.days.ago)
    @dataA = engageData[0]
    @dataB = engageData[1]
    @max = fb_metric.max_value
    @options = fb_metric.options 

    @var = fb_metric.get_engagement_variations_between_dates(page, 8.days.ago.strftime("%Y%m%d"), 1.days.ago.strftime("%Y%m%d"))[:engagement]
  end


  def general
    session[:active_tab] = FACEBOOK

    @user_list = get_active_list

    if params.has_key?(:pages) && params[:pages] != ""

      competitors = []
      num_competitors = 0
      @params_pages = params[:pages] 
      @params_pages.each do |p|
        if page = Page.find_by_id(p.to_i)
           if @user_list.pages.include?(page) and !competitors.include?(page)
             competitors = competitors + [page]
             num_competitors += 1
           end 
        end
      end

      if num_competitors <= 1
        competitors = @user_list.pages
      end

    else 
      competitors = @user_list.pages
    end

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
