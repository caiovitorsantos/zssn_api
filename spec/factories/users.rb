FactoryGirl.define do
  factory :user do
    name FFaker::Name.name
    age { rand(12..70) }
    sex { rand(0..1) }
    latitude FFaker::Geolocation::lat
    longitude FFaker::Geolocation::lng
    healthy FFaker::Boolean::maybe
    count_report { rand(0..3) }
  end
end
