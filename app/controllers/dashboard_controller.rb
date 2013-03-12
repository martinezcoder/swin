class DashboardController < ApplicationController

  before_filter :signed_in_user
  before_filter :user_has_pages
  before_filter :has_active_page
  before_filter :has_competitors

  def main
    if params[:tab] == FACEBOOK
      @min_competitors = 3
      @page = current_user.pages.find_by_id(get_active_page)
      @competitors = @page.competitors.order("fan_count")      
      @num_competitors = @page.competitors.count

      if @num_competitors >= @min_competitors
    
        # update only every if last updated was previous than 2 hours ago 
        if @page.updated_at < 1.hour.ago
          # updating competitor data
          page_ids = []
          @competitors.each do |p|
            page_ids = page_ids + [p.page_id]
          end 
          page_ids = page_ids + [@page.page_id]
          fb_pages_info_list = fb_get_pages_info(page_ids.join(","))
    
          pages_create_or_update(fb_pages_info_list)
        end
    
        @data_nil = []
        @data_nil[0] = ["Competidores", "Likes", "Activos"]
        num = @num_competitors
        for i in 0..num-1 do
          @data_nil[i+1] = [@competitors[i].name, 0, 0]
        end
        @data_nil[num+1] = [@page.name, 0, 0]
    
        @data = []
        @data[0] = ["Competidores", "Likes", "Activos"]
        for i in 0..num-1 do
          @data[i+1] = [@competitors[i].name, @competitors[i].fan_count, @competitors[i].talking_about_count]
        end
        @data[num+1] = [@page.name, @page.fan_count, @page.talking_about_count]
        
        @max_value = @page.competitors.maximum("fan_count")
      end
    else
      redirect_to dashboard_path(tab: FACEBOOK, opt: DEFAULT_OPT)
    end
  end
  
  def engage
  end


private

  def has_active_page
    begin
      redirect_to user_pages_path if get_active_page.nil? 
    rescue
      redirect_to user_pages_path
    end 
  end

  def has_competitors
  end

end
