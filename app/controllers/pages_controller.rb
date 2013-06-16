# encoding: UTF-8

class PagesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
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
      @page = Page.find(thisId)
    end
    @engage = get_engage(@page.fan_count, @page.talking_about_count)

    respond_to do |format|
        format.html # show.html.erb
        format.json {
          options = {
                    seriesType: "area",
                    title:'Timeline engagement (fidelidad de los seguidores)', 
                    titleTextStyle: {fontSize: 14},
                    colors: ['#0088CC'], 
                    height: 200, 
                    animation:{duration: 1500,easing: 'out'}, 
                    hAxes:[{title:'Última semana'}],
                    vAxis: {minValue:0, maxValue:100},
                    fontSize: 10,
                    legend: {position: 'none', textStyle: {fontSize: 14}},
                    tooltip: {isHtml: true}
                  }
          divId = params[:divId] 
          render json:  PageMetrics.new(@page).get_json_engagement_timeline_array(8.days.ago.strftime("%Y%m%d"), 1.days.ago.strftime("%Y%m%d"), options, divId)

        }
    end

  end

 def record_not_found
    redirect_to page_path(35)
  end
  
end
