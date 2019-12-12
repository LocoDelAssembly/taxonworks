FactoryBot.define do
  factory :otu, traits: [:housekeeping] do
    factory :valid_otu do
      name { Faker::Lorem.unique.word }
    end
  end
end
