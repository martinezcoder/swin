# encoding: UTF-8

class PagesController < ApplicationController
  include PagesHelper

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
      @page = Page.find_by_page_id(thisId.split(fbtag).last)
      if @page.nil?
        fb_page = fb_get_pages_info(thisId)
        @page = page_create_or_update(fb_page.first)
      end
      @engage = get_engage(@page.fan_count, @page.talking_about_count)      
    else
      @page = Page.find(thisId)
      @engage = get_engage(@page.fan_count, @page.talking_about_count)      
    end
  end

end
