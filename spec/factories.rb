FactoryGirl.define do

  factory :user do
    name "FranJMartinez"
    email "fran.martinez@ss.com"
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
    page_url "http://www.facebook.com/pages/SocialWin/349679691794392"
    pic_square "http://profile.ak.fbcdn.net/hprofile-ak-snc6/276654_349679691794392_1240268105_q.jpg"
    page_type "CONSULTING/BUSINESS SERVICES"
    username "socialwin"
    pic_big "xxx"
  end
  
  factory :authentication do
    provider "face"
    uid "0"
    user
  end

end
