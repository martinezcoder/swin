module DashboardHelper


  def logo (url, img, options)
    return '<a href="'+ url +'" target="_blank"><img src="'+ img +'" class="'+ options +'"></a>'
  end

  def get_engage(fans, actives)
    if fans > 0
      engage = actives * 5 *100 / fans
    else
      engage = 0
    end
    return engage
  end
end
