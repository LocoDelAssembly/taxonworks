# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    text "MyString"
    note_object_id 1
    note_object_type "MyString"
    note_object_attribute "MyString"
  end
end
