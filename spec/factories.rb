FactoryGirl.define do

  factory :user do
    name "Fran J Martinez"
    email "fran.martinez@socialwin.es"
    terms_of_service "1"
  end

  factory :user0 do
    name "Fran J Martinez"
    email "fran.martinez@socialwin.es"

    factory :admin do
      admin true
    end
  end

  factory :users do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
  end

  factory :page do
    name "SocialWin"
    page_id "349679691794392"
    page_type "CONSULTING/BUSINESS SERVICES"
  end
  
  factory :authentication do
    provider "facebook"
    user
  end

  factory :facebook_list do
    name "listaprueba"
    page_id "000000"
    user
  end

  factory :fb_top_engage do
      day 20130505
      page_id 35
      page_fb_id "349679691794392"
      fan_count 150000
      talking_about_count 15
      variation 3
  end
  

end
