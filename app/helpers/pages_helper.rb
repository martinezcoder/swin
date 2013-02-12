module PagesHelper


  def pages_save_or_update(pagelist)

    pagelist.each do |p|
  
        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")
    
        newpage.update_attributes(
          name: p["name"],
          username: p["username"],
          page_type: p["type"],
          page_url: p["page_url"],
          pic_square: p["pic_square"]
          )
    end

  end

end