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
    attr_accessor :max_value, :options, :error, :metric_name
    
    def initialize(access_token = nil)
      @access_token = access_token
      @max_value = 0
      @error = 0
      @options = {}
      @metric_name = ""
    end

    def get_engagement(fans, actives)
      engagement(fans, actives)      
    end

    def get_variation(old_data, new_data)
      variation(old_data.to_f, new_data.to_f)
    end
    
    def get_engagement_variations_between_dates(page, dayFrom, dayTo)
      begin
        regOld = page.page_data_days.find_by_day(dayFrom)
        regNew = page.page_data_days.find_by_day(dayTo)

        engageOld = engagement(regOld.likes, regOld.prosumers)
        engageNew = engagement(regNew.likes, regNew.prosumers)
        
        fansOld = regOld.likes
        fansNew = regNew.likes
        
        activesOld = regOld.prosumers
        activesNew = regNew.prosumers

        return {engagement: variation(engageOld,  engageNew), 
                     fans: variation(fansOld,    fansNew), 
                  actives: variation(activesOld, activesNew)}
      rescue
      # probably because no data has been catched from these days and this page
        return {engagement: 0, fans: 0, actives: 0}
      end
    end
    
    # Engagement

    def get_top_engagement()
      @error = nil

      return @error || dataResult
    end


    def get_list_in_a_day(page_list, day, metric_name)
      @error = nil
      @metric_name = metric_name
    
      htmls = DashboardHelper::HtmlHardcodes.new()

      pages_metric_array = []
      page_list.each_with_index do |page, i|

        dayPageDataT = page.page_data_days.find_by_day(day.strftime("%Y%m%d").to_i)
        dayPageDataY = page.page_data_days.find_by_day(day.yesterday.strftime("%Y%m%d").to_i)
        dayPageDataYY = page.page_data_days.find_by_day(day.ago(2.days).strftime("%Y%m%d").to_i)

        if dayPageDataT.nil?
          # si no existe el dato pillamos el último día registrado
          dayPageDataT = page.page_data_days.last
          if !dayPageDataT.nil?
puts "****************************************"
puts dayPageDataT.day.to_s
puts dayPageDataT.page_id
            day = Time.strptime(dayPageDataT.day.to_s, "%Y%m%d")
            dayPageDataY = page.page_data_days.find_by_day(day.yesterday.strftime("%Y%m%d").to_i)          
          end
        end

        case @metric_name
        when "Tamano" 
          value_yesterday = (dayPageDataY.nil? ? 0 : dayPageDataY.likes)
          value_today = (dayPageDataT.nil? ? 0 : dayPageDataT.likes)
        when "Actividad"
          value_yesterday = (dayPageDataY.nil? ? 0 : dayPageDataY.prosumers)
          value_today = (dayPageDataT.nil? ? 0 : dayPageDataT.prosumers)
        when "Engagement"
          value_yesterday = (dayPageDataY.nil?? 0 : engagement(dayPageDataY.likes, dayPageDataY.prosumers))
          value_today = (dayPageDataT.nil?? 0 : engagement(dayPageDataT.likes, dayPageDataT.prosumers))
        when "Crecimiento"
          value_yy = (dayPageDataYY.nil?? 0 : dayPageDataYY.likes)
          value_y = (dayPageDataY.nil?? 0 : dayPageDataY.likes)
          value_t = (dayPageDataT.nil?? 0 : dayPageDataT.likes)
          value_yesterday = variation(value_yy.to_f, value_y.to_f)
          value_today     = variation(value_y.to_f, value_t.to_f)
        end

        value_variation = variation(value_yesterday.to_f, value_today.to_f)

        pName = page.name
        pPicture = PagesHelper.get_picture(page, @access_token)
        pUrl = PagesHelper.get_url(page)

        pages_metric_array[i] =  [ htmls.logo(pUrl, pPicture, pName, 'mini_logo'), 
                        pName, 
                        page.page_type, 
                        value_today,
                        htmls.logo(pUrl, pPicture, pName, 'normal_logo'),
                        htmls.html_tooltip(pPicture, pName, value_today, value_variation),
                        htmls.html_variation(value_variation)]
  
        @max_value = [@max_value, value_today].max
      end
      
      pages_metric_array = pages_metric_array.sort_by { |a, b, c, d, e, f| d }
      pages_metric_array = pages_metric_array.reverse

      data_list = []  
      data_list[0] = []
      data_list[1] = []

      pages_metric_array.each_with_index do |page_value, i|
        dataNil = data_list[0][i] = []
        dataNil[0] = (i+1).to_s
        dataNil[1] = dataNil[2] = dataNil[3] = dataNil[5] = dataNil[6] = dataNil[7] = ""
        dataNil[4] = 0
        data_list[1][i] = [(i+1).to_s] + page_value
      end

      @options = "seriesType: 'bars', 
                title:'"+ @metric_name +"',
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

    
    def get_page_timeline(page, date_from, date_to, metric_name)
      @error = nil
      @metric_name = metric_name
      
      dataFirstY  = page.page_data_days.find_by_day(date_from.ago(2.days).strftime("%Y%m%d").to_i)
      dataFirst   = page.page_data_days.find_by_day(date_from.yesterday.strftime("%Y%m%d").to_i)      
      dataRecords = page.page_data_days.select("day, likes, prosumers").where("day between ? and ?", date_from.strftime("%Y%m%d").to_i, date_to.strftime("%Y%m%d").to_i).order('day ASC')

      if dataRecords.count == 0
        @error = "Oooops: no hay datos disponibles para las fechas especificadas :( "
        dataResult = []
        dataResult[0] = []
        dataResult[1] = [] 
      else
        valueList = []

        case @metric_name
        when "Tamano"
          value_yesterday = dataFirst.nil? ? 0 : dataFirst.likes
        when "Actividad"
          value_yesterday = dataFirst.nil? ? 0 : dataFirst.prosumers
        when "Engagement"
          value_yesterday = dataFirst.nil? ? 0 : engagement(dataFirst.likes, dataFirst.prosumers)
        when "Crecimiento"
          value_yy = dataFirstY.nil? ? 0 : dataFirstY.likes
          value_y = dataFirst.nil?  ? 0 : dataFirst.likes
          value_yesterday = variation(value_yy.to_f, value_y.to_f)
        end

        html = DashboardHelper::HtmlHardcodes.new()
        picture = PagesHelper.get_picture(page, @access_token)
        dataRecords.each_with_index do |dataDay, i|     

            case @metric_name
            when "Tamano"
              value_today = dataDay.likes
            when "Actividad"
              value_today = dataDay.prosumers
            when "Engagement"
              value_today = engagement(dataDay.likes, dataDay.prosumers)
            when "Crecimiento"
              value_t = dataDay.likes
              value_today = variation(value_y.to_f, value_t.to_f)
            end

            @max_value = [@max_value, value_today].max
            value_variation = variation(value_yesterday.to_f, value_today.to_f)

            html_tooltip = html.html_tooltip(picture, page.name, value_today, value_variation)
            html_variation = html.html_variation(value_variation)

            valueList[i] =  
                              [ Time.strptime(dataDay.day.to_s, "%Y%m%d").strftime("%d/%m/%Y"), 
                              value_today,
                              html_tooltip,
                              html_variation,
                              dataDay.day]
            
            value_yesterday = value_today  
             
        end

        dataA = []
        dataB = []

        valueList.each_with_index do |day, i|    
          dataA[i] = [] + day
          dataA[i][1] = 0
          dataB[i] = [] + day
        end

        dataResult = []
        dataResult[0] = dataA
        dataResult[1] = dataB 
      end
      @options = "seriesType: 'area', 
                title:'" + @metric_name + "',
                titleTextStyle: {fontSize: 14},
                colors: ['#0088CC'],
                height: 200,
                animation:{duration: 1500,easing: 'out'},
                hAxes:[{title:''}],
                vAxis: {minValue:0, maxValue:" + @max_value.to_s + "},
                fontSize: 10,
                legend: {position: 'none', textStyle: {fontSize: 14}},
                tooltip: {isHtml: true},
                theme: 'maximized'
                "
      return dataResult
    end

    
    def get_list_timeline(page_list, date_from, date_to, metric_name)
      @error = nil
      @metric_name = metric_name
      
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

        if @metric_name == "Crecimiento"
          regs_yesterday = PageDataDay.select("day, page_id, likes, prosumers").where("day = ? and page_id in (?)", time_index.yesterday.strftime("%Y%m%d").to_i, list_ids)
        end

        myArray[row] = []
        myArray[row][0] = time_index.strftime("%Y/%m/%d")

        for column in 1..max_cols
          pid = myArray[0][column]
          p = Page.find_by_id(pid.to_i)
          page_data = regs.find_by_page_id(p.id)
          if !page_data.nil? 
            case @metric_name
            when "Tamano"
              myArray[row][column] = page_data.likes
            when "Actividad"
              myArray[row][column] = page_data.prosumers
            when "Engagement"
              myArray[row][column] = engagement(page_data.likes, page_data.prosumers)
            when "Crecimiento"
              page_data_yesterday = regs_yesterday.find_by_page_id(p.id)
              myArray[row][column] = page_data_yesterday.nil? ? 0 : variation(page_data_yesterday.likes.to_f, page_data.likes.to_f)
            end
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

      @options = "title:'" + @metric_name + "',
                titleTextStyle: {fontSize: 14},
                vAxis: {title: '"+ @metric_name +"'},
                hAxes:[{title:'Día'}],
                seriesType: 'lines',
                fractionDigits: 2,
                suffix: '%'
                " 

      return data_list
    end




    protected

      def engagement(fans, actives)
        
        if fans > 0        
            engage = actives * peso_engage(fans) *100 / fans

            if engage < 100
              engage = (engage/100)*90 
            else
              engage = (90+(engage/100))
            end

        else
            engage = 0
        end

        return engage.round(0)
      end

      def variation(old_data, new_data)
        if old_data == new_data
          variation = 0.0
        else
          variation = ((new_data - old_data) / old_data) * 100
        end
        variation.round(2)
      end
      
    private
     
      def peso_engage(fans)
        case fans
          when 0..9
            0.5
          when 10..99
            1.0
          when 100..299
            2.0
          when 300..999
            3.0
          when 1000..9999
            5.0
          when 10000..99999
            7.0
          when 100000..999999
            10.0
          when 1000000..9999999
            20.0
          when 10000000..49999999
            40.0
          else
            50.0
        end
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
        page_data_day_update(p_id, data_date=Time.now)
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
      pagedata.day = data_date.strftime("%Y%m%d").to_i
      pagedata.save!
  end

  def page_data_stream_update(page_id, data_date=Time.now)
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
        stream.day = data_date.strftime("%Y%m%d").to_i
        stream.save!
      end
    end
  end

  def color_integer(var)
    begin
      if var != 0
        (var > 0 and !var.nil?) ? 'green' : 'red'
      end
    rescue
      'red'
    end 
  end

end