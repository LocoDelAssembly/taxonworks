FactoryBot.define do
  factory :biological_property, class: BiologicalProperty, traits: [:housekeeping] do
    factory :valid_biological_property do
      name { Faker::Lorem.unique.characters(number: 12) }
      definition { Faker::Lorem.unique.sentence(word_count: 6, supplemental: false, random_words_to_add: 3) }
    end
  end
end
