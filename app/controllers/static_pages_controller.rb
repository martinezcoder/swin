class StaticPagesController < ApplicationController
  before_filter :signed_in_user, only: :habla
  before_filter :user_is_admin, only: [:admin, :test, :query_test]
  
  def home
    if signed_in?
      redirect_to facebook_engage_path
    else
      @pages = Page.count
      @users = User.count
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

  def query_test

    if params[:chart] == 'test0'

      render json: { 
        type: params[:type] || 'BarChart',
        cols: [["string","Fecha"],["number","Engage"], ["string", "competidor"]],
        rows: [["2013-04-06",83, "A"],
                  ["2013-04-07",83, "A"],
                  ["2013-04-08",89, "A"],
                  ["2013-04-09",96, "A"],
                  ["2013-04-10",114, "A"],
                  ["2013-04-11",115, "A"],
                  ["2013-04-12",118, "A"]],
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

    end

  end


end
