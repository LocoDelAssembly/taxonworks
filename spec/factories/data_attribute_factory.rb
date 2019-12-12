FactoryBot.define do
  factory :data_attribute, traits: [:creator_and_updater] do
    factory :valid_data_attribute do
      type { 'ImportAttribute' }
      association :attribute_subject, factory: :valid_otu
      import_predicate { Faker::Lorem.unique.words(number: 2).join(' ') }
      value { Faker::Number.unique.number(digits: 5) }
    end
  end
end
