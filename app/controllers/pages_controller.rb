# encoding: UTF-8

class PagesController < ApplicationController
  include PagesHelper
  include FacebookHelper

  before_filter :user_is_admin, only: [:admin_query]

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

        me = User.find_by_email("fran.martinez@socialwin.es")
        fb_token = me.authentications.find_by_provider(FACEBOOK).token
        fb_graph  = Koala::Facebook::API.new(fb_token)
        strQuery = "SELECT page_id, type, name, fan_count, talking_about_count from page WHERE page_id = #{thisId}"
        fb_page = fb_graph.fql_query(strQuery)
        
        
        #fb_page = fb_get_pages_info(thisId)
        @page = page_create_or_update(fb_page.first)
      end
      @engage = get_engage(@page.fan_count, @page.talking_about_count)      
    else
      @page = Page.find(thisId)
      @engage = get_engage(@page.fan_count, @page.talking_about_count)      
    end
  end

end
