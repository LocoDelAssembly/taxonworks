FactoryBot.define do

  trait :creator_and_updater do
    created_by_id { Current.user_id }
    updated_by_id { Current.user_id }
  end

  trait :projects do
    project_id { Current.project_id }
  end

  trait :housekeeping do
    creator_and_updater
    projects
  end

end
