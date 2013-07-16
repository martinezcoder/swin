# encoding: UTF-8

class FacebookController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :has_active_list
  before_filter :list_has_pages, except: :empty

  before_filter :dates_filter, only: [:dashboard, :engage, :size, :growth, :activity]
  before_filter :pages_filter, only: [:engage, :size, :growth, :activity]

  before_filter :set_active_tab
  
  def empty
    @list = get_active_list
    @num_competitors = @list.pages.count
  end

  def dashboard
    metric_type = M_DASHBOARD
    @user_list = get_active_list

    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK))
    @date_from = @date_from.yesterday if @date_from == @date_to
    @data = fb_metric.get_dashboard_metrics(@page, @date_from, @date_to)
  end

  def engage
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
      @date_to = Time.now.yesterday
      @graph_type = 0
      @list = get_active_list.pages # all competitors      
      data = fb_metric.get_list_in_a_day(@list, @date_to, metric_type)      
    end

    @dataA = data[0]
    @dataB = data[1]
    @options = fb_metric.options 
  end

  def size
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
      @date_to = Time.now.yesterday
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
      @date_to = Time.now.yesterday
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
      @date_to = Time.now.yesterday
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

  def set_active_tab
    session[:active_tab] = FACEBOOK    
  end

  def dates_filter
    @date_from = nil
    @date_to = nil
    @graph_type = nil
    @user_list = nil 
    @list = nil
    @page = Page.find_by_id(get_active_list.page_id)
    
    # Tenemos tres opciones de gráficas: 
    # 0 - barras de crecimiento de un solo día y varios competidores
    # 2 - timeline de crecimiento de un solo competidor desde/hasta
    # 3 - timeline de crecimiento de varios competidores desde/hasta
    is_day       = 0
    is_timeline  = 1
    
    begin
      pre_update_params
      if user_plan?(FREE)
        @date_to = Time.now.yesterday
        if params.has_key?(:ndays) and params[:ndays] != ""
          ndays =  params[:ndays].to_i
          if ndays > current_user.plan.max_date_range 
            ndays = current_user.plan.max_date_range
            params[:ndays] = ndays
          end
          @date_from = @date_to.ago(ndays.day)
          @graph_type = is_timeline
        else
          @date_from = @date_to
          @graph_type = is_day
        end
      else
        if params.has_key?(:ndays) and params[:ndays] != ""
          @date_to = Time.now.yesterday
          ndays =  params[:ndays].to_i
          if ndays > current_user.plan.max_date_range 
            ndays = current_user.plan.max_date_range
            params[:ndays] = ndays
          end
          @date_from = @date_to.ago(ndays.day)
          @graph_type = is_timeline
        else
          if params.has_key?(:date_from) && params.has_key?(:date_to)
              @date_from = Time.strptime(params[:date_from], "%Y/%m/%d") # historic timeline
              @date_to = Time.strptime(params[:date_to], "%Y/%m/%d")
              dateRange = (@date_to - @date_from)/60/60/24
              @graph_type = is_timeline
              if dateRange < 0 
                flash[:info] = "ATENCIÓN: rango de fechas no válido"
                raise
              elsif dateRange > current_user.plan.max_date_range
                flash[:info] = "ATENCIÓN: el rango debe ser inferior a #{current_user.plan.max_date_range} días"
                raise
              elsif @date_from == @date_to
                @graph_type = is_day
              end
              
          elsif params.has_key?(:date_to)
              @date_to = Time.strptime(params[:date_to], "%Y/%m/%d") # historic day
              @date_from = @date_to
          else
              @date_to = Time.now - (24*60*60) # yesterday
              @date_from = @date_to
          end
        end
      end
    rescue
      flash[:info] = "Opps, algo no ha ido bien..." if flash[:info].nil?
      @date_to = Time.now - (24*60*60) # yesterday
      @date_from = @date_to
      @graph_type = is_day
    end
    post_update_params
  end


  def pages_filter
    is_day       = 0
    is_timeline  = 1
    is_timeline_single = 2
    is_timeline_multi  = 3
    
    if @graph_type.nil? 
      @graph_type = is_day
    end

    @user_list = get_active_list

    @list = []
    
    if user_plan?(FREE) and (@graph_type == is_timeline)
      @page = Page.find_by_id(get_active_list.page_id)
      @list = @list + [@page]
      @graph_type = is_timeline_single
    else
      params_pages = []
      if params.has_key?(:pages) && params[:pages] != ""
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

  def pre_update_params
    if !session[:params].nil?
      if params[:date_from].nil? && !session[:params][:dates][:from].nil?
        params[:date_from] = session[:params][:dates][:from]
      end
      if params[:date_to].nil? && !session[:params][:dates][:to].nil?
        params[:date_to] = session[:params][:dates][:to]
      end
      if params[:ndays].nil? && !session[:params][:dates][:ndays].nil?
        params[:ndays] = session[:params][:dates][:ndays]
      end
      if params[:pages].nil? && !session[:params][:pages].nil?
        params[:pages] = session[:params][:pages]
      end

      #params[:ndays] = session[:params][:dates][:ndays] if !params.has_key?(ndays) && !session[:params][:dates][:ndays].nil?
    end   
  end
  
  def post_update_params
    session[:params] = { dates: {
                                 ndays: params[:ndays], 
                                 from:  params[:date_from], 
                                 to:    params[:date_to]
                                },
                         pages:  params[:pages]
                       }
  end

end
