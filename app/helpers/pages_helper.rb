# encoding: UTF-8

module PagesHelper
  include FacebookHelper

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
    
    begin
      fbpages = fb_my_admin_pages_info
    rescue
      flash[:info] = "Facebook no responde. Por favor, inténtelo más tarde."
      sign_out
      redirect_to root_path
    end

    pages_create_or_update(fbpages)

  end


end