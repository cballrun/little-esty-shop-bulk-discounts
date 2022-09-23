require 'faker'


FactoryBot.define do
  factory :bulk_discount do
    percentage { rand(1..100) }
    quantity { rand(5..20 )}
    merchant
  end
end 