FactoryGirl.define do

  factory :user do
    name "FranJMartinez"
    email "fran.martinez@ss.com"
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
