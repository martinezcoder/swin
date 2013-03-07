class DashboardController < ApplicationController
before_filter :signed_in_user
before_filter :user_has_pages
before_filter :has_active_page
before_filter :has_competitors

  def main
    @page = current_user.pages.find_by_id(get_active_page)

    num = @page.competitors.count
    competitors = @page.competitors.order("fan_count")
    
    @data_nil = []
    @data_nil[0] = ["Competidores", "Likes", "Activos"]        
    for i in 0..num-1 do
      @data_nil[i+1] = [competitors[i].name, 0, 0]
    end

    @data = []
    @data[0] = ["Competidores", "Likes", "Activos"]
    for i in 0..num-1 do
      @data[i+1] = [competitors[i].name, competitors[i].page_data_days.last.likes, competitors[i].page_data_days.last.prosumers]
    end

    @max_value = @page.competitors.maximum("fan_count")
  end
  
  def engage
  end

private

  def has_active_page
    begin
      redirect_to pages_index_path if get_active_page.nil? 
    rescue
      redirect_to pages_index_path
    end 
  end

  def has_competitors
  end

end
