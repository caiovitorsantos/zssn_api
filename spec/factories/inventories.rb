FactoryGirl.define do
  factory :inventory do
    user 
    kind { rand(0..3) }
    amount { rand(0..20) }
  end
end
