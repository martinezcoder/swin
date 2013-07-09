# encoding: UTF-8

class PagesController < ApplicationController
#  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  before_filter :user_is_admin, only: [:admin_query]

  include PagesHelper
  include FacebookHelper

  # it will rend a graph with the evolution of the number of monitored pages by day
  def admin_query
    @ndays = params[:days] || 62

    days = (@ndays).to_i
    render :json => {
      :type => 'LineChart',
      :cols => [['string', 'Fecha'], ['number', 'pages']],
      :rows => (1..days).to_a.inject([]) do |memo, i|
                  date = i.days.ago.to_date
                  t = date.beginning_of_day
                  pages = PageDataDay.where("day = #{t.strftime("%Y%m%d").to_i}").count
                  memo << [date, pages]
                  memo
                end.reverse,
      :options => {
        :chartArea => { :width => '80%', :height => '75%' }, 
        :hAxis => { :showTextEvery => 30 } 
      }
    }
  end


  def show
    fbtag = "fb-"
    thisId = params[:id]
    if thisId.include?(fbtag)
      thisId = thisId.split(fbtag).last
      @page = Page.find_by_page_id(thisId)
      if @page.nil?
#        me = User.find_by_email("fran.martinez@socialwin.es")
#        fb_token = me.authentications.find_by_provider(FACEBOOK).token
        fb_page = FacebookHelper::FbGraphAPI.new().get_page_info(thisId)
        @page = page_create_or_update(fb_page[0])
      end
    else
      @page = Page.find_by_id(thisId)
    end

    begin
      if params.has_key?(:day)
        day = params[:day].to_time
        raise if day >= Time.now.beginning_of_day
      else
        day = Time.now.yesterday
      end
    rescue
      day = Time.now.yesterday
    ensure
      @day = day.strftime('%d/%m/%Y')
    end

#    fb_metric = PagesHelper::FbMetrics.new(get_token(FACEBOOK))
    fb_metric = PagesHelper::FbMetrics.new()
    engageData = fb_metric.get_page_timeline(@page, day.ago(7.days), day, M_ENGAGEMENT)
    @dataA = engageData[0]
    @dataB = engageData[1]
    @options = fb_metric.options

    if (@error = fb_metric.error)
      @error = "Oops, esta página es nueva para nosotros, tendrás que esperar unos días..."
    end

    
    @data_day = PageDataDay.find_by_page_id_and_day(@page.id, day.strftime('%Y%m%d'))

    if @data_day.nil?
      # por si falla el proceso diario o es una nueva página
      @data_day = PageDataDay.new()
      @data_day.likes = @page.fan_count 
      @data_day.prosumers = @page.talking_about_count
    end

    @engage = fb_metric.get_engagement(@data_day.likes, @data_day.prosumers)

    @variations = {}
    if @data_day_week_ago = PageDataDay.find_by_page_id_and_day(@page.id, day.ago(6.days).strftime('%Y%m%d'))
      likes_week_ago     = @data_day_week_ago.likes
      prosumers_week_ago = @data_day_week_ago.prosumers
      engage_week_ago    = fb_metric.get_engagement(likes_week_ago, prosumers_week_ago)
      @variations[:engage] = fb_metric.get_variation(engage_week_ago, @engage)
      @variations[:likes]  = fb_metric.get_variation(likes_week_ago, @data_day.likes)
      @variations[:prosumers] = fb_metric.get_variation(prosumers_week_ago, @data_day.prosumers)
    else
      @variations[:engage] = nil
      @variations[:likes]  = nil
      @variations[:prosumers] = nil
    end

    @thisUrl = request.url
    if !@thisUrl.include?("?day")
      @thisUrl += "?day=" + day.strftime('%Y%m%d')
    end
    
  end


  def record_not_found
    redirect_to page_path(35)
  end
  
end
