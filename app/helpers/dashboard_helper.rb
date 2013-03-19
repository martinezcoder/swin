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
  
  
   def tooltip(img, title, eng)
     ret = 
     '<div style="padding:5px 5px 5px 5px;'+ 
                 'text-align: center;'+
                 '">' +
     '<div style="font-size: 1.7em;color: #0088CC"><strong>'+ eng.to_s + '</strong></div><br>'+
     '<img src="'+ img +'"><br>' + title
     return ret
   end
  
end
