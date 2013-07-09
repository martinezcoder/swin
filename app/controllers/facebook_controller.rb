# encoding: UTF-8

class FacebookController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :has_active_list
  before_filter :list_has_pages, except: :empty

  before_filter :member_user, only: [:engage, :size, :growth, :activity]

  def empty
    session[:active_tab] = FACEBOOK
    @list = get_active_list
    @num_competitors = @list.pages.count
  end


  def engage
    session[:active_tab] = FACEBOOK

    metric_type = M_ENGAGEMENT
 
    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 
    case @graph_type
      when 0
        data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)
      when 2
        data = fb_metric.get_page_timeline(@page, @date_from, @date_to, metric_type)
      when 3
        data = fb_metric.get_list_timeline(@list, @date_from, @date_to, metric_type)
    end

    @errors = fb_metric.error
    if !@errors.nil?
      flash[:info] = @errors
      @date_to = Time.now - (24*60*60) # yesterday
      @graph_type = 0
      @list = get_active_list.pages # all competitors      
      data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)      
    end

    @dataA = data[0]
    @dataB = data[1]
    @options = fb_metric.options 
  end

  def size
    session[:active_tab] = FACEBOOK

    metric_type = M_TAMANO
 
    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 
    case @graph_type
      when 0
        data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)
      when 2
        data = fb_metric.get_page_timeline(@page, @date_from, @date_to, metric_type)
      when 3
        data = fb_metric.get_list_timeline(@list, @date_from, @date_to, metric_type)
    end

    @errors = fb_metric.error
    if !@errors.nil?
      flash[:info] = @errors
      @date_to = Time.now - (24*60*60) # yesterday
      @graph_type = 0
      @list = get_active_list.pages # all competitors      
      data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)      
    end

    @dataA = data[0]
    @dataB = data[1]
    @options = fb_metric.options 
    @metric_name = "Tamaño"
  end

  def growth
    session[:active_tab] = FACEBOOK

    metric_type = M_CRECIMIENTO
 
    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 
    case @graph_type
      when 0
        data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)
      when 2
        data = fb_metric.get_page_timeline(@page, @date_from, @date_to, metric_type)
      when 3
        data = fb_metric.get_list_timeline(@list, @date_from, @date_to, metric_type)
    end

    @errors = fb_metric.error
    if !@errors.nil?
      flash[:info] = @errors
      @date_to = Time.now - (24*60*60) # yesterday
      @graph_type = 0
      @list = get_active_list.pages # all competitors      
      data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)      
    end

    @dataA = data[0]
    @dataB = data[1]
    @options = fb_metric.options 
    @metric_name = fb_metric.metric_name

  end

  def activity
    session[:active_tab] = FACEBOOK

    metric_type = M_ACTIVIDAD
 
    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK)) 
    case @graph_type
      when 0
        data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)
      when 2
        data = fb_metric.get_page_timeline(@page, @date_from, @date_to, metric_type)
      when 3
        data = fb_metric.get_list_timeline(@list, @date_from, @date_to, metric_type)
    end

    @errors = fb_metric.error
    if !@errors.nil?
      flash[:info] = @errors
      @date_to = Time.now - (24*60*60) # yesterday
      @graph_type = 0
      @list = get_active_list.pages # all competitors      
      data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)      
    end

    @dataA = data[0]
    @dataB = data[1]
    @options = fb_metric.options 
    @metric_name = fb_metric.metric_name
  end


private

  def member_user
    @date_from = nil
    @date_to = nil
    @graph_type = nil
    @user_list = nil 
    @list = nil
    
    # Tenemos tres opciones de gráficas: 
    # 0 - barras de crecimiento de un solo día y varios competidores
    # 2 - timeline de crecimiento de un solo competidor desde/hasta
    # 3 - timeline de crecimiento de varios competidores desde/hasta
    is_day       = 0
    is_timeline  = 1

    begin
      if !membership_user?
        @date_to = Time.now - (24*60*60) # yesterday
        @graph_type = is_day
      else
        if params.has_key?(:date_from) && params.has_key?(:date_to)
            @date_from = Time.strptime(params[:date_from], "%Y%m%d") # historic timeline
            @date_to = Time.strptime(params[:date_to], "%Y%m%d")
            dateRange = (@date_to - @date_from)/60/60/24
            @graph_type = is_timeline
            if dateRange < 0 
              flash[:info] = "ATENCIÓN: rango de fechas no válido"
              raise
            elsif dateRange > MAX_DATE_RANGE
              flash[:info] = "ATENCIÓN: el rango debe ser inferior a tres meses"
              raise
            elsif @date_from == @date_to
              @graph_type = is_day
            end
            
        elsif params.has_key?(:date_to)
            @date_to = Time.strptime(params[:date_to], "%Y%m%d") # historic day
        else
            @date_to = Time.now - (24*60*60) # yesterday
        end
      end
    rescue
      flash[:info] = "Opps, algo no ha ido bien..." if flash[:info].nil?
      @date_to = Time.now - (24*60*60) # yesterday
      @graph_type = is_day
    end

    set_graph_type(@graph_type)
  end


  def set_graph_type(grType)
    is_day       = 0
    is_timeline  = 1
    # Hasta aquí:
    # @graph_type = is_timeline ==> Si existe date_from y date_to con fechas diferentes
    # @graph_type = is_day      ==> en cualquier otro caso
    is_timeline_single = 2
    is_timeline_multi  = 3

    @graph_type = grType
    
    if @graph_type.nil? 
      @graph_type = is_day
    end

    @user_list = get_active_list

    params_pages = []
    
    if params.has_key?(:pages) && params[:pages] != ""

      @list = []
      num_competitors = 0
      params_pages = params[:pages] 
      params_pages.each do |p|
        if page = Page.find_by_id(p.to_i)
           if @user_list.pages.include?(page) and !@list.include?(page)
             @list = @list + [page]
             num_competitors += 1
           end 
        end
      end

      if num_competitors > 1
        @graph_type = is_timeline_multi if @graph_type == is_timeline
      elsif num_competitors == 1
        if @graph_type == is_timeline
          @graph_type = is_timeline_single 
          @page = Page.find_by_id(params_pages[0])
        else
          @list = get_active_list.pages
        end
      else
        @graph_type = is_day
        @list = get_active_list.pages # all competitors      
      end

    else
      @graph_type = is_timeline_multi if @graph_type == is_timeline 
      @list = get_active_list.pages
    end

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
