module PagesHelper


  def pages_create_or_update(pagelist)

    pagelist.each do |p|

        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")

        newpage.name = p["name"]
        newpage.username = p["username"]
        newpage.page_type = p["type"]
        newpage.page_url = p["page_url"]
        newpage.pic_square = p["pic_square"]
        newpage.save!

    end

  end

end