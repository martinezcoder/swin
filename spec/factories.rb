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
    page_url "http://www.facebook.com/pages/SocialWin/349679691794392"
    page_type "CONSULTING/BUSINESS SERVICES"
    username "socialwin"
    pic_big "xxx"
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


end
