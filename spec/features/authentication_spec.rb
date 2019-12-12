require 'rails_helper'

describe 'Authentication', type: :feature do

  subject { page }

  describe '/signin' do

    context 'when credentials match existing user' do

      let(:valid_user) { FactoryBot.create(:valid_user, id: 1) }

      it 'should sign user in' do
        sign_in_with(valid_user.email, Rails.configuration.x.test_user_password )

        expect(subject).to have_link('Account') # TODO, add href
        expect(subject).not_to have_link('Sign out', href: signin_path)

        expect(subject).to have_content 'Dashboard' 
        expect(subject).to have_content 'Projects' 
      end
    end

    context 'when credentials do not match existing user' do
      it 'should not sign user in' do
        visit signin_path
        fill_in 'Email', with: '' 
        fill_in 'Password', with: '' 
        click_button 'Sign in'
        expect(subject).to have_title('TaxonWorks - Sessions')
        expect(subject).to have_button('Sign in')
        expect(subject).not_to have_link('Sign out', href: signout_path)
        expect(subject).not_to have_content 'Signed in as user'
        expect(subject).not_to have_link('Account')
      end
    end
  end

  describe '/signout' do
    before do
      sign_in_user
    end

    it 'should log user out', js: true do
      click_link 'Sign out'
      expect(subject).to have_button('Sign in')
      expect(subject).not_to have_link('Sign out', href: signout_path)
      expect(subject).not_to have_content 'Signed in as user'
      expect(subject).not_to have_content('Your account')
    end
 
  end 
end
