FactoryBot.define do
  factory :observation_matrix, traits: [:housekeeping] do
    factory :valid_observation_matrix do
      name { Faker::Lorem.unique.word }
    end
  end
end
