module DashboardHelper


  def ndays_plan_constraint_class(label_for, link_class, link_text, link_type)

    if user_plan?(FREE)
      if request.path == facebook_engage_path
        if link_type > 7
          link_class += ' disabled'
        end
      else
        if link_type > 0
          link_class += ' disabled'
        end
      end
    end
    
    content_tag(:label, :for => label_for) do
      concat(content_tag(:li, class: link_class) do
          link_text
      end)
    end

  end

  def date_range_plan_constraint_class
    if user_plan?(FREE)
      false 
    else
      true
    end
  end

  def dashboard_box(link_path, title, value, variation, percent=false)

    class_name = "btn past "
    if !variation.nil?
      if variation > 0 
        class_name += " past-green"
      elsif variation < 0
        class_name += " past-orange"
      end
    end
        
    link_to link_path, class: class_name do
      concat(content_tag(:div, class: "past-title") do
          title
      end)
      concat(content_tag(:div, class: "past-percent") do
          value.to_s + (percent ? '%' : '')
      end)
      if !percent
        concat(content_tag(:div, class: "past-var") do
            variation.to_s + '%' if !variation.nil?
        end)
      end
    end

  end
  

  class HtmlHardcodes

      def logo (url, img, title, options)
        return '<a href="'+ url +'" target="_blank"><img src="'+ img +'" class="'+ options +'" title="'+ title +'"></a>'
      end
      
      def html_tooltip(img, title, value, variation)
          ret = 
         '<div style="padding:5px 5px 5px 5px;'+ 
                     'text-align: center;'+
                     'align:center;'+
                     '">'+
            '<div style="'+
                        'padding:5px 5px 5px 5px;'+
                        'font-size: 1.7em;'+
                        'color: #0088CC;'+
                        '">'+
                '<strong>'+ value.to_s + '</strong>'+
            '</div>'+
            '<strong>'+  if variation >= 0 
                            '<span style="color:green">+' + sprintf("%.2f", variation) 
                         else
                            '<span style="color:red">' + sprintf("%.2f", variation)
                         end + '%</span></strong>' +
    
            '<div style="'+
                        'margin:10px 0px;'+
                        '">'+
            '<img src="'+ img +'">'+
            '</div>'+
            '<strong>'+ title + '</strong>' +
          '</div>'
    
         return ret
      end    
    
      def html_variation(variation)
          ret = '<div style="margin-left:10px;">'
          if variation == 0
            ret += '<span style="color:green">'
          elsif variation > 0
            ret += '<i class="icon-arrow-up"></i> ' + '<span style="color:green">'
          else
            ret += '<i class="icon-arrow-down"></i> ' '<span style="color:red">'
          end
          return ret + sprintf("%.2f", variation)  + '%</span></div>' 
      end

    
  end

  def chart_tag (height, params = {})
    params[:format] ||= :json
    if params[:chart] == 'pages'
      path = pages_admin_query_path(params: params)
    elsif params[:chart] == 'usuarios'
      path = users_admin_query_path(params: params)
    end
    content_tag(:div, :'data-query-chart' => path, :style => "height: #{height}px;") do
      image_tag('loader.gif', :size => '24x24', :class => 'spinner')
    end
  end
  
end
