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
  
  
   def tooltip(img, title, value)
      ret = 
     '<div style="padding:5px 5px 5px 5px;'+ 
                 'text-align: center;'+
                 'align:center;'+
#                 'background:url(/assets/body-tail.gif) 0 0 repeat-x #fff;'+
                 '">'+
        '<div style="'+
                    'margin:0 auto 10px auto;'+
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
                    'margin-bottom:10px;'+
                    '">'+
        '<img src="'+ img +'">'+
        '</div>'+
        '<strong>'+ title + '</strong>' +
      '</div>'

     return ret
   end





  
end
