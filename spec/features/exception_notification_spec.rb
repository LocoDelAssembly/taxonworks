require 'rails_helper'

describe 'Exception notification', type: :feature do
  before { ActionMailer::Base.deliveries.clear }
  
  it 'sends an email when an exception occurs' do
    (visit crash_test_path) rescue nil
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  it 'includes user email in message when signed in' do
    sign_in_user
    (visit crash_test_path) rescue nil
    expect(ActionMailer::Base.deliveries.last.body).to match(/:user_id=>\d+, :user_email=>"user@example.com"/)
  end
  
  it 'includes project in message when signed in and project selected' do
    sign_in_user_and_select_project
    (visit crash_test_path) rescue nil
    expect(ActionMailer::Base.deliveries.last.body).to match(/:project_id=>\d+, :project_name=>"My Project"/)
  end

end
