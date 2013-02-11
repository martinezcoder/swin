module UsersHelper

  def image_for(user)
    user_picture = "https://graph.facebook.com/#{get_auth(FACEBOOK).uid}/picture" 
    image_tag(user_picture, alt: user.name, class: "gravatar")
  end
end
