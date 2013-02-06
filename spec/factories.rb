FactoryGirl.define do

  factory :user do
    name "mi tester"
    email "tester@socialwin.es"
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

end
