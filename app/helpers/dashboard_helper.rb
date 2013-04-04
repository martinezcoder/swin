module DashboardHelper

  def logo (url, img, title, options)
    return '<a href="'+ url +'" target="_blank"><img src="'+ img +'" class="'+ options +'" title="'+ title +'"></a>'
  end

  def get_engage(fans, actives)
    if fans > 0
      engage = actives * 5 *100 / fans
    else
      engage = 0
    end
    return engage
  end
  
  def get_variation(today, yesterday)
    return ((today - yesterday) / yesterday) * 100
  end
  
  def html_tooltip_engage(img, title, value, variation)
      ret = 
     '<div style="padding:5px 5px 5px 5px;'+ 
                 'text-align: center;'+
                 'align:center;'+
                 '">'+
        '<strong>'+  if variation >= 0 
                        '<span style="color:green">+' + sprintf( "%0.01f", variation) 
                     else
                        '<span style="color:red">' + sprintf( "%0.01f", variation)
                     end + '%</span></strong>' +

        '<div style="'+
                    'margin:10px auto 10px auto;'+
                    'width: 30px;'+
                    'padding: 2px  5px;'+
                    'font-size: 1.7em;'+
                    'color: #FFF;'+
  
                    'border: 1px solid #0088CC;'+ 
                    'background-color: #0088CC;'+
  
                    '-moz-border-radius: 5px;'+
                    '-webkit-border-radius: 5px;'+
                    'border-radius: 5px;'+
                    
                    '-moz-box-shadow: rgb(150,150,150) 2px 2px 2px;'+
                    '-webkit-box-shadow: rgb(150,150,150) 2px 2px 2px;'+
                    'box-shadow: rgb(150,150,150) 2px 2px 2px;'+
                    '">'+
            '<strong>'+ value.to_s + '</strong>'+
        '</div>'+
        '<div style="'+
                    'margin:10px 0px;'+
                    '">'+
        '<img src="'+ img +'">'+
        '</div>'+
        '<strong>'+ title + '</strong>' +
      '</div>'

     return ret
  end
  
  def html_tooltip_general(img, title, fans, actives)
      ret = 
     '<div style="padding:5px 5px 5px 5px;'+ 
                 'text-align: center;'+
                 'align:center;'+
                 '">'+
        '<p><strong>'+ title + '</strong></p>' +
        '<div style="'+
                    'margin-bottom:10px;'+
                    '">'+
        '<img src="'+ img +'">'+
        '</div>'+
        '<p>Fans: <strong>'+ fans.to_s.reverse.gsub(/...(?=.)/,'\&.').reverse + '</strong>' +
        '<br/>Activos: <strong>'+ actives.to_s.reverse.gsub(/...(?=.)/,'\&.').reverse + '</strong></p>' +
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
      return ret + sprintf( "%0.01f", variation)  + '%</span></div>' 
  end
  
end
