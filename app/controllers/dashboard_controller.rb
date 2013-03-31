# encoding: UTF-8

class DashboardController < ApplicationController
include DashboardHelper

  before_filter :signed_in_user
  before_filter :user_has_pages
  before_filter :has_active_page
  before_filter :has_competitors, except: :no_competitors

  def no_competitors
    session[:active] = { tab: FACEBOOK, opt: OPT_NO_COMPETITORS }
    @page = current_user.pages.find_by_id(get_active_page)
    @num_competitors = @page.competitors.count
  end

  def engage
    session[:active] = { tab: FACEBOOK, opt: OPT_ENGAGE }    
    @page = current_user.pages.find_by_id(get_active_page)    

    competitors = []
    competitors[0] = @page
    competitors = competitors + @page.competitors   

    css1 = 'mini_logo'
    css2 = 'normal_logo'

    num = competitors.length
    compList = []
    for i in 0..num-1 do
      engage = get_engage(competitors[i].fan_count, competitors[i].talking_about_count)
      compList[i] = [ logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      engage,
                      logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css2),
                      tooltip_engage(competitors[i].pic_square, competitors[i].name, engage)]
    end

    compList = compList.sort_by { |a, b, c, d, e, f| d }
    compList = compList.reverse

    @dataA = []
    @dataB = []
 
    for i in 0..compList.length-1 do
      @dataA[i] = [(i+1).to_s] + compList[i]
      @dataA[i][4] = 0
      @dataB[i] = [(i+1).to_s] + compList[i]
    end

    @max = compList[0][3]
    
    @max = 50 if @max <= 50 

  end

  def general
    session[:active] = { tab: FACEBOOK, opt: OPT_GENERAL }
    @page = current_user.pages.find_by_id(get_active_page)

    competitors = []
    competitors[0] = @page
    competitors = competitors + @page.competitors   

    # update only every if last updated was previous than 1 hours ago 
    if @page.updated_at < -1.hour.ago
      # updating competitor data
      page_ids = []
      competitors.each do |p|
        page_ids = page_ids + [p.page_id]
      end 
      page_ids = page_ids + [@page.page_id]
      fb_pages_info_list = fb_get_pages_info(page_ids.join(","))

      pages_create_or_update(fb_pages_info_list)
    end

    css1 = 'mini_logo'
    css2 = 'normal_logo'

    num = competitors.length
    compList = []
    for i in 0..num-1 do
      compList[i] = [ logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css1), 
                      competitors[i].name, 
                      competitors[i].page_type, 
                      competitors[i].fan_count,
                      competitors[i].talking_about_count,
                      logo(competitors[i].page_url, competitors[i].pic_square, competitors[i].name, css2),
                      tooltip_general(competitors[i].pic_square, competitors[i].name, competitors[i].fan_count, competitors[i].talking_about_count)]
    end

    compList = compList.sort_by { |a, b, c, d, e, f, g| d }
    compList = compList.reverse

    @dataA = []
    @dataB = []
 
    for i in 0..compList.length-1 do
      @dataA[i] = [(i+1).to_s] + compList[i]
      @dataA[i][4] = 0
      @dataA[i][5] = 0
      @dataB[i] = [(i+1).to_s] + compList[i]
    end

    @max_fans = compList[0][3]
    @max_actives = compList[0][4]
 

  end

private

  def has_active_page
    begin
      redirect_to user_pages_path(current_user) if get_active_page.nil? 
    rescue
      redirect_to user_pages_path(current_user)
    end 
  end

  def has_competitors
    begin
      min_competitors = 1
      page = current_user.pages.find_by_id(get_active_page)
      num_competitors = page.competitors.count
      if num_competitors < min_competitors
        redirect_to dashboard_no_competitors_path
      end
    rescue
      redirect_to dashboard_no_competitors_path
    end
  end

end
