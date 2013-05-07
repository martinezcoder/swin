module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "SocialWin Analytics"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end



  def menu_link(link_text, icon_type, link_path)
    class_name = current_page?(link_path) ? 'active' : ''
   
    content_tag(:li, :class => class_name) do
      link_to link_path do
        content_tag(:i, '', :class => icon_type) + ' ' + link_text
      end
    end

  end

end
