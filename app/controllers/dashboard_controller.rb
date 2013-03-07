class DashboardController < ApplicationController
before_filter :signed_in_user
before_filter :user_has_pages

  def main
    @page = current_user.pages.find(get_active_page)

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
end
