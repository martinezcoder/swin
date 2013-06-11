# encoding: UTF-8

class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: [:habla, :admin, :test, :test2, :query_test]
  before_filter :user_is_admin, only: [:admin, :test, :test2, :query_test]
  
  def home
    if signed_in?
      redirect_to facebook_engage_path
    else
      @pages = Page.count
      @users = User.count
      @searching = false

      if params.has_key?(:search) && params[:search] != ""
        @searching = true
        if params[:search].include?("https://www.facebook.com")
          subUrl = params[:search].split('/').last.split('?').first
          subUrl = subUrl + '?fields=id,name'
        else
          subUrl = "search?type=page&q=" + params[:search]
        end
        @fb_search_path = "https://graph.facebook.com/" + subUrl
      end
    end
  end


  def habla
    session[:active_tab] = FACEBOOK
  end

  def twitter
    session[:active_tab] = TWITTER
  end

  def youtube
    session[:active_tab] = YOUTUBE
  end

  def admin
    @ndays = params[:days] || 62
  end  

  def test
  end

  def test2
  end


  def query_test

    if params[:chart] == 'test0'

      render json: { 
        type: params[:type] || 'BarChart',
        cols: [["string","Fecha"],["number","Engage"]],
        rows: [["2013-04-06",83],
                  ["2013-04-07",83],
                  ["2013-04-08",89],
                  ["2013-04-09",96],
                  ["2013-04-10",114],
                  ["2013-04-11",115],
                  ["2013-04-12",118]],
        options: 
        {
=begin
          chartArea: {width:"90%", height:"75%"},
          hAxis: {showTextEvery:2},
          legend: ""
=end
        }
      }

    elsif params[:chart] == 'test1'

      render json: { 
        type: params[:type] || 'LineChart',
        cols: [["string","Mes"], ["number","Bolivia"], ["number","Ecuador"]],
        rows: [['2004/05',  165,      938],
               ['2005/06',  135,      1120],
               ['2006/07',  157,      1167],
               ['2007/08',  139,      1110],
               ['2008/09',  136,      691]],
        options: {}
      }

    elsif params[:chart] == 'gcolumn'
  
       render json: {
                cols: [
                      {id:"",label:"Topping",pattern:"",type:"string"},
                      {id:"",label:"Slices", pattern:"",type:"number"},
                      {id: "", role: "tooltip", type: "string", p: { role: "tooltip" } } 
                    ],
                rows: [
                      {c:[{v:"Mushrooms",f:nil},{v:3,f:nil}, {v: "24 April, Price - 56000, Seller-abcd"}]},
                      {c:[{v:"Onions",   f:nil},{v:1,f:nil}, {v: "24 April, Price - 56000, Seller-abcd"}]},
                      {c:[{v:"Olives",   f:nil},{v:1,f:nil}, {v: "24 April, Price - 56000, Seller-abcd"}]},
                      {c:[{v:"Zucchini", f:nil},{v:1,f:nil}, {v: "24 April, Price - 56000, Seller-abcd"}]},
                      {c:[{v:"Pepperoni",f:nil},{v:2,f:nil}, {v: "24 April, Price - 56000, Seller-abcd"}]}
                    ],
                 options:
                 { seriesType: "bars",
                   width: 375, height: 240,
                           legend: 'none',
                           pointSize: 5,
                           backgroundColor: 'transparent',
                           vAxis: { minValue: 0, maxValue: 10 }
                         }
              }
    end

  end


end
