class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      if ss_active_page == "0"
        redirect_to pages_index_path
      else
        @page = current_user.pages.find_by_id(ss_active_page)

        num = @page.competitors.count
        
        @data_nil = []
        @data_nil[0] = ["Competidores", "Likes", "Prosumers"]        
        for i in 0..num-1 do
          @data_nil[i+1] = [@page.competitors[i].name, 0, 0]
        end


        @data = []
        @data[0] = ["Competidores", "Likes", "Prosumers"]
        
        for i in 0..num-1 do
          @data[i+1] = [@page.competitors[i].name, @page.competitors[i].page_data_days.last.likes, @page.competitors[i].page_data_days.last.prosumers]
        end

        @max_value = @page.competitors.maximum("fan_count")

      end
    end
  end

  def help
  end


  def about
  end

end
