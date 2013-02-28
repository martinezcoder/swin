class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      if ss_active_page == "0"
        redirect_to pages_index_path
      else
        @page = current_user.pages.find_by_id(ss_active_page)

        @data_nil = [["Competidores", "Likes", "Prosumers"],['SEAT',0,0],['FIAT',0,0],['TOYOTA',0,0],['PEUGEOT',0,0],['CITROEN',0,0]]
        @data = []
        @data[0] = ["Competidores", "Likes", "Prosumers"]
        @data[1] = ['SEAT', 64169, 1206]
        @data[2] = ['FIAT', 11792, 434]
        @data[3] = ['TOYOTA', 28018, 2200]
        @data[4] = ['PEUGEOT', 84795, 2567]
        @data[5] = ['CITROEN', 76615, 2336]

      end
    end
  end

  def help
  end


  def about
  end

end
