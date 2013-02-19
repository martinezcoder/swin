# encoding: UTF-8

module PagesHelper

  def page_create_or_update(p)
        newpage = Page.find_or_initialize_by_page_id("#{p["page_id"]}")

        newpage.name = p["name"]
        newpage.username = p["username"]
        newpage.page_type = p["type"]
        newpage.page_url = p["page_url"]
        newpage.pic_square = p["pic_square"]
        newpage.save!
  end


  def pages_create_or_update(pagelist)
    pagelist.each do |p|
      user_page = page_create_or_update(p)
      current_user.set_page!(Page.find_by_page_id("#{p["page_id"]}"))
    end
  end



  def pages_update_from_facebook
    
    ftoken = get_token FACEBOOK
    
    begin
      fgraph  = Koala::Facebook::API.new(ftoken)
      fbpages = fgraph.fql_query("SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (SELECT page_id from page_admin where uid=me())")

    rescue
      flash[:info] = "Facebook no responde. Por favor, inténtelo más tarde."
      sign_out
      redirect_to root_path
    end
    
    pages_create_or_update(fbpages)

  end


end