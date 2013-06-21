# encoding: UTF-8

module PagesHelper

  def get_url(page)
    PagesHelper.get_url(page) #ret = "https://www.facebook.com/" + page.page_id.to_s
  end
  
  def get_picture(page, big=false)
    fb_token = signed_in? ? get_token(FACEBOOK) : nil
    PagesHelper.get_picture(page, fb_token, big)
  end

  class << self
    def get_picture(page, access_token, big=false)
      ret = "https://graph.facebook.com/" + page.page_id.to_s + "/picture?"
      if big
        ret += "type=large&"
      end
      ret += "access_token=" + access_token if access_token
      return page.pic_square || ret
      # El siguiente método comentado permite que se muestren logos de marcas de bebidas alcohólicas. El problema con esta llamada está en que, para cada página mostrada realiza una llamada a la API de Facebook desde nuestro servidor, ralentizando enormemente el renderizado de la página.
      # Para que muestre todas las páginas debemos pasarle el token de facebook...
      # Actualmente el logo lo recogemos haciendo referencia a la url: graph.facebook.com/id/picture
      # De este modo, es el usuario quien realiza la petición a facebook y descarga al servidor de esta tarea. Pero desgraciadamente, no muestra los logos para marcas de bebidas alcoholicas puesto que para ello hace falta un token de usuario para que Facebook pueda identificar su edad. 
      # FacebookHelper::FbGraphAPI.new(get_token(FACEBOOK)).get_picture(page.page_id)
      # FacebookHelper::FbGraphAPI.new().get_picture(page.page_id)
    end
    
    def get_url(page)
      ret = "https://www.facebook.com/" + page.page_id.to_s
    end
  end 


  class FbMetrics
    attr_accessor :max_value, :options, :error
    
    def initialize(access_token = nil)
      @access_token = access_token
      @max_value = 0
      @error = 0
      @options = {}
    end

    def get_engagement(fans, actives)
       engagement(fans, actives)      
    end
    
    def get_variation_between_dates(page, dayFrom, dayTo)
      begin
        reg = page.page_data_days.select("day, likes, prosumers").where("day = ?", dayFrom)
        valueBefore = engagement(reg[0].likes, reg[0].prosumers)
        reg = page.page_data_days.select("day, likes, prosumers").where("day = ?", dayTo)
        valueAfter = engagement(reg[0].likes, reg[0].prosumers)
        return variation(valueAfter, valueBefore)
      rescue
        return 0
      end      
    end
    
    # Engagement

    def get_top_engagement()
      @error = nil

      return @error || dataResult
    end
    
    def get_page_engagement_timeline(page, date_from, date_to)
      @error = nil

      dataRecords = page.page_data_days.select("day, likes, prosumers").where("day between ? and ?", date_from.strftime("%Y%m%d").to_i, date_to.strftime("%Y%m%d").to_i).order('day ASC')

      if dataRecords.count == 0
        @error = "Oooops: no hay datos disponibles para las fechas especificadas :( "
      else
          engageYesterday = 0
          engageList = []

          html = DashboardHelper::HtmlHardcodes.new()
          picture = PagesHelper.get_picture(page, @access_token)
          dataRecords.each_with_index do |dataDay, i|     
              engageToday = engagement(dataDay.likes, dataDay.prosumers)
              @max_value = [@max_value, engageToday].max
              variation = variation(engageToday.to_f, engageYesterday.to_f)

              html_tooltip = html.html_tooltip_engage(picture, page.name, engageToday, variation)
              html_variation = html.html_variation(variation)

              engageList[i] =  
                                [ Time.strptime(dataDay.day.to_s, "%Y%m%d").strftime("%d/%m/%Y"), 
                                engageToday,
                                html_tooltip,
                                html_variation,
                                dataDay.day]
              
              engageYesterday = engageToday
          end

          dataA = []
          dataB = []

          engageList.each_with_index do |day, i|    
            dataA[i] = [] + day
            dataA[i][1] = 0
            dataB[i] = [] + day
          end

          dataResult = []
          dataResult[0] = dataA
          dataResult[1] = dataB 
      end

      return @error || dataResult
    end

    
    def get_list_engagement_timeline(page_list, date_from, date_to)
      @error = nil

      max_cols = page_list.count
      
      time_index = date_from
      time_end = date_to

      myArray = []
      myArray[0] = []
      myArray[0][0] = 'Dia'

      page_list.each_with_index do |p, i|
        myArray[0][i+1] = p.id
      end

      list_names = Page.select('id, name').where("id in (?)", page_list)
      list_ids = list_names.pluck(:id)

      row = 1
      while time_index <= time_end
        regs = PageDataDay.select("day, page_id, likes, prosumers").where("day = ? and page_id in (?)", time_index.strftime("%Y%m%d").to_i, list_ids)
        
        myArray[row] = []
        myArray[row][0] = time_index.strftime("%Y/%m/%d")

        for column in 1..max_cols
          pid = myArray[0][column]
          p = Page.find_by_id(pid.to_i)
          page_data = regs.where("page_id = ?", p.id)
          if page_data.count > 0
            myArray[row][column] = engagement(page_data.first.likes, page_data.first.prosumers)
          else
            myArray[row][column] = -1
          end

        end
       
        row += 1
        time_index = time_index.tomorrow
      end
      
      page_list.each_with_index do |page, i|
        myArray[0][i+1] = page.name
      end

      data_list = []  
      data_list[0] = myArray
      data_list[1] = myArray
      return data_list
    end


    def get_list_engagement_day(page_list, day)
      @error = nil
      
      htmls = DashboardHelper::HtmlHardcodes.new()

      pages_engage_array = []
      page_list.each_with_index do |page, i|

        dayPageData = page.page_data_days.where("day = #{day.yesterday.strftime("%Y%m%d").to_i}")
        engage_yesterday = (dayPageData.empty?? 0 : engagement(dayPageData[0].likes, dayPageData[0].prosumers))
        
        dayPageData = page.page_data_days.where("day = #{day.strftime("%Y%m%d").to_i}")
        engage_today = (dayPageData.empty?? 0 : engagement(dayPageData[0].likes, dayPageData[0].prosumers))

        engage_variation = variation(engage_today.to_f,engage_yesterday.to_f)

        pName = page.name
        pPicture = PagesHelper.get_picture(page, @access_token)
        pUrl = PagesHelper.get_url(page)

        pages_engage_array[i] =  [ htmls.logo(pUrl, pPicture, pName, 'mini_logo'), 
                        pName, 
                        page.page_type, 
                        engage_today,
                        htmls.logo(pUrl, pPicture, pName, 'normal_logo'),
                        htmls.html_tooltip_engage(pPicture, pName, engage_today, engage_variation),
                        htmls.html_variation(engage_variation)]
  
        @max_value = [@max_value, engage_today].max
      end
      
      pages_engage_array = pages_engage_array.sort_by { |a, b, c, d, e, f| d }
      pages_engage_array = pages_engage_array.reverse

      data_list = []  
      data_list[0] = []
      data_list[1] = []

      pages_engage_array.each_with_index do |page_engage, i|
        dataNil = data_list[0][i] = []
        dataNil[0] = (i+1).to_s
        dataNil[1] = dataNil[2] = dataNil[3] = dataNil[5] = dataNil[6] = dataNil[7] = ""
        dataNil[4] = 0
        data_list[1][i] = [(i+1).to_s] + page_engage
      end

      @options =     "seriesType: 'bars', 
                title:'Day Engagement (fidelidad de los seguidores)',
                titleTextStyle: {fontSize: 14},
                colors: ['#0088CC'],
                height: 200,
                animation:{duration: 1500,easing: 'out'},
                hAxes:[{title:'Competidores'}],
                vAxis: {minValue:0, maxValue:" + @max_value.to_s + "},
                fontSize: 10,
                legend: {position: 'none', textStyle: {fontSize: 14}},
                tooltip: {isHtml: true}" 
      return data_list
    end

    # Tamaño
    def get_page_size_timeline(page, date_start, date_end)
      @error = nil
    end    
    
    def get_list_size_timeline(page_list, date_start, date_end)
      @error = nil
      if date_start == date_end
        get_list_size_day(list, date_start)
      end      
    end

    def get_list_size_day(page_list, date)
      @error = nil
    end
    
    protected

      def engagement(fans, actives)
        if fans > 0
          engagement = actives * 6 *100 / fans
        else
          engagement = 0
        end
        engagement
      end
  
      def variation(new_data, old_data)
        ((new_data - old_data) / old_data) * 100
      end

  end


  def page_create_or_update(p, stream=false, daily=false)
      newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")

      newpage.name = p["name"]
      newpage.page_type = p["type"]
      newpage.fan_count = p["fan_count"]
      newpage.talking_about_count = p["talking_about_count"]
      newpage.save!
      if stream == UPDATE_STREAM
        page_data_stream_update(page_id)
      end

      if daily == UPDATE_DAY
        page_data_day_update(p_id, data_date=Time.now.beginning_of_day)
      end

      newpage
  end

  def pages_create_or_update(pagelist)
    pagelist.each do |p|
      user_page = page_create_or_update(p)
    end
  end

  def my_admin_pages_update_from_facebook    
    begin
      fbpages = FacebookHelper::FbGraphAPI.new(get_token(FACEBOOK)).get_my_admin_pages_info
    rescue
      flash[:info] = "Facebook no responde. Por favor, inténtelo más tarde."
      sign_out
      redirect_to root_path
    end
    fbpages.each do |p|
      user_page = page_create_or_update(p)
      current_user.rel_user_page!(Page.find_by_page_id("#{p["page_id"]}"))
    end
  end

  def page_data_day_update(p_id, data_date=Time.now)
      page = Page.find_by_id(p_id)
      pagedata = PageDataDay.find_or_initialize_by_page_id_and_day(page.id, data_date.strftime("%Y%m%d").to_i)     
      pagedata.likes = page.fan_count
      pagedata.prosumers = page.talking_about_count
      pagedata.comments = page.page_streams.sum("comments_count") || 0
      pagedata.shared = page.page_streams.sum("share_count") || 0
      pagedata.total_likes_stream = page.page_streams.sum("likes_count") || 0
      pagedata.posts = page.page_streams.count || 0
      pagedata.day = data_date.to_i
      pagedata.save!
  end

  def page_data_stream_update(page_id)
    fb_page_id = Page.find_by_id(page_id).page_id
    page_stream = FacebookHelper::FbGraphAPI.new(get_token(FACEBOOK)).get_page_stream(fb_page_id)

    for i in 0..page_stream.count-1
      ps = page_stream[i]
      if !ps["permalink"].nil? and !ps["permalink"].empty? 
        stream = PageStream.find_or_initialize_by_page_id_and_created_time(page_id, ps["created_time"])
        stream.post_id = ps["post_id"]
        stream.permalink = ps["permalink"]
        if !ps["attachment"]["media"].nil? 
          if !ps["attachment"]["media"][0].nil?
            stream.media_type = ps["attachment"]["media"][0]["type"]
          end
        end 
        stream.actor_id = ps["actor_id"]
        stream.target_id = ps["target_id"]
        stream.likes_count = ps["likes"]["count"]
        stream.comments_count = ps["comments"]["count"]
        stream.share_count = ps["share_count"] 
        stream.created_time = ps["created_time"]
        stream.day = Time.now.yesterday.beginning_of_day
        stream.save!
      end
    end
  end

end