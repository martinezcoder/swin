Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, {scope: "read_stream, email, manage_pages, read_insights" }
  provider :twitter, TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET
end
