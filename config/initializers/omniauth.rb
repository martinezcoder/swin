Rails.application.config.middleware.use OmniAuth::Builder do  
  if Rails.env.production?
    provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, {scope: "read_stream, email, manage_pages, read_insights" }
  else 
    provider :facebook, FACEBOOK_APP_ID_DEV, FACEBOOK_APP_SECRET_DEV, {scope: "read_stream, email, manage_pages, read_insights" }
  end
    
  provider :twitter, TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET
end
