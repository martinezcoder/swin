# encoding: UTF-8

class FacebookController < ApplicationController
include DashboardHelper

  before_filter :tipo, only: :growth

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

      begin
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
      rescue
        list = get_active_list.pages
        num_competitors = list.count
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
        engageData = fb_metric.get_list_in_a_day(list, date_to, M_ENGAGEMENT)
      when engage_timeline_single
        engageData = fb_metric.get_page_timeline(page, date_from, date_to, M_ENGAGEMENT)
      when engage_timeline_multi
        engageData = fb_metric.get_list_timeline(list, date_from, date_to, M_ENGAGEMENT)
    end


    @errors = fb_metric.error
    if @errors.nil?
      @dataA = engageData[0]
      @dataB = engageData[1]
      #@max = fb_metric.max_value
      @options = fb_metric.options 
      @metric_name = fb_metric.metric_name
    else
      flash[:info] = @errors
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = engage_day
      list = get_active_list.pages # all competitors      
      engageData = fb_metric.get_list_in_a_day(list, date_to, M_ENGAGEMENT)         
    end

  end

  def size
    session[:active_tab] = FACEBOOK

    # Tenemos tres opciones de gráficas: 
    # 1 - barras de tamaño de un solo día y varios competidores
    # 2 - timeline de tamaño de un solo competidor desde/hasta
    # 3 - timeline de tamaño de varios competidores desde/hasta
    size_day       = 0
    size_timeline  = 1

    @type_graph = nil

    begin
      if !membership_user?
        date_to = Time.now - (24*60*60) # yesterday
        @type_graph = size_day
      else
        if params.has_key?(:date_from) && params.has_key?(:date_to)
            date_from = Time.strptime(params[:date_from], "%Y%m%d") # historic timeline
            date_to = Time.strptime(params[:date_to], "%Y%m%d")
            dateRange = (date_to - date_from)/60/60/24
            @type_graph = size_timeline
            if dateRange < 0 
              flash[:info] = "ATENCIÓN: rango de fechas no válido"
              raise
            elsif dateRange > MAX_DATE_RANGE
              flash[:info] = "ATENCIÓN: el rango debe ser inferior a tres meses"
              raise
            elsif date_from == date_to
              @type_graph = size_day
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
      @type_graph = size_day
    end

    if @type_graph.nil? 
      @type_graph = size_day
    end

    # Hasta aquí:
    # @type_graph = size_timeline ==> Si existe date_from y date_to con fechas diferentes
    # @type_graph = size_day      ==> en cualquier otro caso

    size_timeline_single = 2
    size_timeline_multi  = 3

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
        @type_graph = size_timeline_multi if @type_graph == size_timeline
      elsif num_competitors == 1
        if @type_graph == size_timeline
          @type_graph = size_timeline_single 
          page = Page.find_by_id(@params_pages[0])
        else
          list = get_active_list.pages
        end
      else
        @type_graph = size_day
        list = get_active_list.pages # all competitors      
      end

    else
      @type_graph = size_timeline_multi if @type_graph == size_timeline 
      list = get_active_list.pages
    end

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 

    case @type_graph
      when size_day
        sizeData = fb_metric.get_list_in_a_day(list, date_to, M_TAMANO)
      when size_timeline_single
        sizeData = fb_metric.get_page_timeline(page, date_from, date_to, M_TAMANO)
      when size_timeline_multi
        sizeData = fb_metric.get_list_timeline(list, date_from, date_to, M_TAMANO)
    end

    @errors = fb_metric.error
    if @errors.nil?
      @dataA = sizeData[0]
      @dataB = sizeData[1]
      #@max = fb_metric.max_value
      @options = fb_metric.options 
      @metric_name = "Tamaño"
    else
      flash[:info] = @errors
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = size_day
      list = get_active_list.pages # all competitors      
      sizeData = fb_metric.get_list_in_a_day(list, date_to, M_TAMANO)         
    end    
  end


  def growth
    session[:active_tab] = FACEBOOK

    metric = M_CRECIMIENTO
    # Tenemos tres opciones de gráficas: 
    # 1 - barras de crecimiento de un solo día y varios competidores
    # 2 - timeline de crecimiento de un solo competidor desde/hasta
    # 3 - timeline de crecimiento de varios competidores desde/hasta
    growth_day       = 0
    growth_timeline  = 1

    @type_graph = nil

    begin
      if !membership_user?
        date_to = Time.now - (24*60*60) # yesterday
        @type_graph = growth_day
      else
        if params.has_key?(:date_from) && params.has_key?(:date_to)
            date_from = Time.strptime(params[:date_from], "%Y%m%d") # historic timeline
            date_to = Time.strptime(params[:date_to], "%Y%m%d")
            dateRange = (date_to - date_from)/60/60/24
            @type_graph = growth_timeline
            if dateRange < 0 
              flash[:info] = "ATENCIÓN: rango de fechas no válido"
              raise
            elsif dateRange > MAX_DATE_RANGE
              flash[:info] = "ATENCIÓN: el rango debe ser inferior a tres meses"
              raise
            elsif date_from == date_to
              @type_graph = growth_day
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
      @type_graph = growth_day
    end

    if @type_graph.nil? 
      @type_graph = growth_day
    end

    # Hasta aquí:
    # @type_graph = growth_timeline ==> Si existe date_from y date_to con fechas diferentes
    # @type_graph = growth_day      ==> en cualquier otro caso

    growth_timeline_single = 2
    growth_timeline_multi  = 3

    @user_list = get_active_list

    params_pages = []
    
    if params.has_key?(:pages) && params[:pages] != ""

      list = []
      num_competitors = 0
      params_pages = params[:pages] 
      params_pages.each do |p|
        if page = Page.find_by_id(p.to_i)
           if @user_list.pages.include?(page) and !list.include?(page)
             list = list + [page]
             num_competitors += 1
           end 
        end
      end

      if num_competitors > 1
        @type_graph = growth_timeline_multi if @type_graph == growth_timeline
      elsif num_competitors == 1
        if @type_graph == growth_timeline
          @type_graph = growth_timeline_single 
          page = Page.find_by_id(params_pages[0])
        else
          list = get_active_list.pages
        end
      else
        @type_graph = growth_day
        list = get_active_list.pages # all competitors      
      end

    else
      @type_graph = growth_timeline_multi if @type_graph == growth_timeline 
      list = get_active_list.pages
    end

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 

    case @type_graph
      when growth_day
        growthData = fb_metric.get_list_in_a_day(list, date_to, @metric_type)
      when growth_timeline_single
        growthData = fb_metric.get_page_timeline(page, date_from, date_to, @metric_type)
      when growth_timeline_multi
        growthData = fb_metric.get_list_timeline(list, date_from, date_to, @metric_type)
    end

    @errors = fb_metric.error
    if @errors.nil?
      @dataA = growthData[0]
      @dataB = growthData[1]
      #@max = fb_metric.max_value
      @options = fb_metric.options 
      @metric_name = fb_metric.metric_name
    else
      flash[:info] = @errors
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = growth_day
      list = get_active_list.pages # all competitors      
      growthData = fb_metric.get_list_in_a_day(list, date_to, @metric_type)
    end    
  end


  def activity
    session[:active_tab] = FACEBOOK

    # Tenemos tres opciones de gráficas: 
    # 1 - barras de actividad de un solo día y varios competidores
    # 2 - timeline de actividad de un solo competidor desde/hasta
    # 3 - timeline de actividad de varios competidores desde/hasta
    activity_day       = 0
    activity_timeline  = 1

    @type_graph = nil

    begin
      if !membership_user?
        date_to = Time.now - (24*60*60) # yesterday
        @type_graph = activity_day
      else
        if params.has_key?(:date_from) && params.has_key?(:date_to)
            date_from = Time.strptime(params[:date_from], "%Y%m%d") # historic timeline
            date_to = Time.strptime(params[:date_to], "%Y%m%d")
            dateRange = (date_to - date_from)/60/60/24
            @type_graph = activity_timeline
            if dateRange < 0 
              flash[:info] = "ATENCIÓN: rango de fechas no válido"
              raise
            elsif dateRange > MAX_DATE_RANGE
              flash[:info] = "ATENCIÓN: el rango debe ser inferior a tres meses"
              raise
            elsif date_from == date_to
              @type_graph = activity_day
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
      @type_graph = activity_day
    end

    if @type_graph.nil? 
      @type_graph = activity_day
    end

    # Hasta aquí:
    # @type_graph = activity_timeline ==> Si existe date_from y date_to con fechas diferentes
    # @type_graph = activity_day      ==> en cualquier otro caso

    activity_timeline_single = 2
    activity_timeline_multi  = 3

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
        @type_graph = activity_timeline_multi if @type_graph == activity_timeline
      elsif num_competitors == 1
        if @type_graph == activity_timeline
          @type_graph = activity_timeline_single 
          page = Page.find_by_id(@params_pages[0])
        else
          list = get_active_list.pages
        end
      else
        @type_graph = activity_day
        list = get_active_list.pages # all competitors      
      end

    else
      @type_graph = activity_timeline_multi if @type_graph == activity_timeline 
      list = get_active_list.pages
    end

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 

    case @type_graph
      when activity_day
        activityData = fb_metric.get_list_in_a_day(list, date_to, M_ACTIVIDAD)
      when activity_timeline_single
        activityData = fb_metric.get_page_timeline(page, date_from, date_to, M_ACTIVIDAD)
      when activity_timeline_multi
        activityData = fb_metric.get_list_timeline(list, date_from, date_to, M_ACTIVIDAD)
    end

    @errors = fb_metric.error
    if @errors.nil?
      @dataA = activityData[0]
      @dataB = activityData[1]
      #@max = fb_metric.max_value
      @options = fb_metric.options 
      @metric_name = fb_metric.metric_name
    else
      flash[:info] = @errors
      date_to = Time.now - (24*60*60) # yesterday
      @type_graph = activity_day
      list = get_active_list.pages # all competitors      
      activityData = fb_metric.get_list_in_a_day(list, date_to, M_ACTIVIDAD)
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
    engageData = fb_metric.get_page_timeline(page, 16.days.ago, 1.days.ago, "Engagement")
    @dataA = engageData[0]
    @dataB = engageData[1]
    @max = fb_metric.max_value
    @options = fb_metric.options 

    @var = fb_metric.get_engagement_variations_between_dates(page, 8.days.ago.strftime("%Y%m%d"), 1.days.ago.strftime("%Y%m%d"))[:engagement]
  end


private
  attr_accessor :metric_type

  def tipo
   @metric_type = M_CRECIMIENTO
  end

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
