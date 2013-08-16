module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "FanPagesCompare"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def menu_link(link_text, icon_type, link_path, link_class)
    class_name = (request.path == link_path) ? 'active' : ''
    content_tag(:li, :class => class_name) do
      link_to link_path, class: link_class do
        icon_type.nil? ? link_text : content_tag(:i, '', :class => icon_type) + ' ' + link_text
      end
    end
  end

  def tab_link(link_text, link_path, tab, anchor)
    if tab == get_active_tab
      class_name = 'active'
    else
      class_name = ''
    end 

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path, anchor
    end
  end

end
