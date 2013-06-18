# encoding: UTF-8

module PagesHelper

  def get_url(page)
    PagesHelper.get_url(page) #ret = "https://www.facebook.com/" + page.page_id.to_s
  end
  
  def get_picture(page, big=false)
    PagesHelper.get_picture(page, get_token(FACEBOOK), big)
  end

  class << self
    def get_picture(page, access_token, big=false)
      ret = "https://graph.facebook.com/" + page.page_id.to_s + "/picture?"
      if big
        ret += "type=large&"
      end
      ret += "access_token=" + access_token
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
    attr_accessor :max_value, :options
    
    def initialize(access_token)
      @access_token = access_token
      @max_value = 0
      @error = 0
      @options = {}
    end
    
    # Engagement
    
    def get_page_engagement_timeline(page, date_start, date_end)
    end
    
    def get_list_engagement_timeline(page_list, date_start, date_end)
      if date_start == date_end
        get_list_engagement_day(list, date_start)
      end      
    end

    def get_list_engagement_day(page_list, day)

      htmls = DashboardHelper::HtmlHardcodes.new()

      pages_engage_array = []
      page_list.each_with_index do |page, i|

#        dayPageData = page.page_data_days.where("day = #{day.strftime("%Y%m%d").to_i}")
        dayPageData = page.page_data_days.where("day = #{day.yesterday.strftime("%Y%m%d").to_i}")
        engage_yesterday = (dayPageData.empty?? 0 : engagement(dayPageData[0].likes, dayPageData[0].prosumers))
        
        dayPageData = page.page_data_days.where("day = #{day.strftime("%Y%m%d").to_i}")
        engage_today = (dayPageData.empty?? 0 : engagement(dayPageData[0].likes, dayPageData[0].prosumers))

#        engage_today     = engagement(page.fan_count, page.talking_about_count)
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
      
      #@max_value = 50  if @max_value <= 50

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
                tooltip: {isHtml: true}
                " 
      return data_list
    end

    # Tamaño
    def get_page_size_timeline(page, date_start, date_end)
    end    
    
    def get_list_size_timeline(page_list, date_start, date_end)
      if date_start == date_end
        get_list_size_day(list, date_start)
      end      
    end

    def get_list_size_day(page_list, date)
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

    def variation(new, old)
      ((new - old) / old) * 100
    end

  end


  def page_engageTimeline_chart_tag (height, params = {})
    params[:format] ||= :json
    jsonPath = page_path(params: params)
    content_tag(:div, :id => params[:divId], :'data-chart' => jsonPath, :style => "height: #{height}px;") do
      image_tag('loader.gif', :size => '24x24', :class => 'spinner')
    end
  end



  class PageMetrics
    attr_accessor :max, :graphOptions
    
    def initialize(page, access_token)
      @max = 0
      @error = nil
      @page = page
      @graphOptions = {}
      @access_token = access_token
    end

    def engagement(fans, actives)
      if fans > 0
        engagement = actives * 6 *100 / fans
      else
        engagement = 0
      end
      engagement
    end

    def variation(today, yesterday)
      ((today - yesterday) / yesterday) * 100
    end

    def get_variation(dayFrom, dayTo)
      begin
        reg = @page.page_data_days.select("day, likes, prosumers").where("day = ?", dayFrom)
        valueBefore = engagement(reg[0].likes, reg[0].prosumers)
        reg = @page.page_data_days.select("day, likes, prosumers").where("day = ?", dayTo)
        valueAfter = engagement(reg[0].likes, reg[0].prosumers)
        return variation(valueAfter, valueBefore)
      rescue
        return 0
      end      
    end

    def get_json_engagement_timeline_array(date_from, date_to, options, divId)
      dataRecords = @page.page_data_days.select("day, likes, prosumers").where("day between ? and ?", date_from[0,8], date_to[0,8]).order('day ASC')

      if dataRecords.count == 0
        options[:title] = "Ooops, esta página es nueva para SocialWin. Tendrás que esperar unos días para ver esta gráfica completa..."
        options[:titleTextStyle] = {color: '#0000FF', fontSize: 14}
          
      end
      engageYesterday = 0
      engageList = []
      counter = 0

      picture = PagesHelper.get_picture(@page, @access_token)
      dataRecords.each do |dataDay|     
            engageToday = engagement(dataDay.likes, dataDay.prosumers)
            @max = [@max, engageToday].max
            variation = variation(engageToday.to_f, engageYesterday.to_f)
            
            html = DashboardHelper::HtmlHardcodes.new()
            html_tooltip = html.html_tooltip_engage(picture, @page.name, engageToday, variation)
            html_variation = html.html_variation(variation)

            engageList[counter] = {}
            engageList[counter][:c] = []
            engageList[counter][:c][0] = 0
            engageList[counter][:c][1] = {v: Time.strptime(dataDay.day.to_s, "%Y%m%d").strftime("%d/%m/%Y"), f:nil}
            engageList[counter][:c][2] = {v: engageToday,    f:nil}
            engageList[counter][:c][3] = {v: html_tooltip,   f:nil}
            engageList[counter][:c][4] = {v: html_variation, f:nil}
            engageList[counter][:c][5] = {v: dataDay.day,    f:nil}

            engageYesterday = engageToday
            counter += 1
      end
          
      @max = 50 if @max <= 50 
      options[:vAxis] = {minValue: 0, maxValue: @max}

      @dataResult =  {}
      @dataResult[:divId] = divId
      @dataResult[:options] = options
      @dataResult[:graphShowCols] = [1,2,3]
      @dataResult[:cols] = [
                      {id:"",label:"dataNil",pattern:"",type:"number"},
                      {id:"",label:"Fecha",pattern:"",type:"string"},
                      {id:"",label:"Engagement", pattern:"",type:"number"},
                      {id:"",type: "string", p: { role: "tooltip", html: true } },
                      {id:"",label:"Variación", pattern:"",type:"number"},
                      {id:"",label:"Id", pattern:"",type:"number"}
                    ]    
      @dataResult[:rows] = engageList        

      @dataResult

    end

    def get_timeline_array(date_from, date_to)
      @dataResult = []
      
      dataRecords = @page.page_data_days.select("day, likes, prosumers").where("day between ? and ?", date_from[0,8], date_to[0,8]).order('day ASC')

      engageYesterday = 0
      engageList = []
      counter = 0
      
      if dataRecords.count == 0

        @dataResult[0] = "[{error: no hay datos disponibles para las fechas especificadas}]"

      else

          picture = PagesHelper.get_picture(@page, @access_token)
          dataRecords.each do |dataDay|     
              engageToday = engagement(dataDay.likes, dataDay.prosumers)
              @max = [@max, engageToday].max
              variation = variation(engageToday.to_f, engageYesterday.to_f)
              
              html = DashboardHelper::HtmlHardcodes.new()
              html_tooltip = html.html_tooltip_engage(picture, @page.name, engageToday, variation)
              html_variation = html.html_variation(variation)
              
              engageList[counter] =  
                                [ Time.strptime(dataDay.day.to_s, "%Y%m%d").strftime("%d/%m/%Y"), 
                                engageToday,
                                html_tooltip,
                                html_variation,
                                dataDay.day]
              
              engageYesterday = engageToday
              counter += 1
          end
  
          dataA = []
          dataB = []
       
          for i in 0..counter-1    
            dataA[i] = [] + engageList[i]
            dataA[i][1] = 0
            dataB[i] = [] + engageList[i]
          end
          @dataResult[1] = dataA
          @dataResult[2] = dataB
          
          @max = 50 if @max <= 50 

      end

      @dataResult

    end

  end

  
  def get_engage(fans, actives)
    if fans > 0
      engage = actives * 6 *100 / fans
    else
      engage = 0
    end
    return engage
  end
  
  def get_variation(today, yesterday)
    return ((today - yesterday) / yesterday) * 100
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
#    page_stream = fb_get_page_stream(fb_page_id)

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