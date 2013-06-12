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

        @page = page_create_or_update(fb_page.first)
      end
    else
      @page = Page.find(thisId)
    end
    @engage = get_engage(@page.fan_count, @page.talking_about_count)

    respond_to do |format|
        format.html # show.html.erb
        format.json { 
          render json: 
          {

                cols: [
                      {id:"",label:"Fecha",pattern:"",type:"string"},
                      {id:"",label:"Engagement", pattern:"",type:"number"},
                      {id:"",label:"Variación", pattern:"",type:"number"},
                      {id: "",role: "tooltip", type: "string", p: { role: "tooltip" } } 
                    ],
                rows: [
                      {c:[{v:"Lunes",    f:nil}, {v:30,f:nil}, {v:15,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Martes",   f:nil}, {v:25,f:nil}, {v:10,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Miércoles",f:nil}, {v:40,f:nil}, {v:20,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Jueves",   f:nil}, {v:44,f:nil}, {v:5,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Viernes",  f:nil}, {v:55,f:nil}, {v:30,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Sábado",   f:nil}, {v:60,f:nil}, {v:30,f:nil}, {v: "Engagement"}]},
                      {c:[{v:"Domingo",  f:nil}, {v:40,f:nil}, {v:-10,f:nil}, {v: "Engagement"}]}
                    ],
                 options:
                   { seriesType: "bars",
#                     series: {1: {type: "line"}},
#                     series: [{type: "bars"}, {type: "line"}],
                     series: [nil, {type: "line"}],
                     width: 375, 
                     height: 240,
                     legend: 'none',
                     pointSize: 5,
                     backgroundColor: 'transparent',
                     vAxis: { minValue: 0, maxValue: 100 }
                    }
          }  
        }
    end

  end

end
