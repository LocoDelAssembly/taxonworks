require 'rails_helper'

describe User do

  let(:user) { User.new(password: 'password',
                        password_confirmation: 'password',
                        email: 'user_model@example.com')}
  subject { user }

  context 'associations' do
    context 'has_many' do
      specify 'projects' do
        expect(user.projects << Project.new()).to be_truthy
      end
    end
  end

  context 'preferences' do
    specify '#favorite_routes' do
      expect(user.favorite_routes).to eq([])
    end

    specify '#recent_routes' do
      expect(user.recent_routes).to eq([])
    end
  end

  context 'authorization' do
    context 'when just a user' do
      specify '#is_administrator? is false' do
        expect(user.is_administrator?).to be(false)
      end

      specify '#is_project_administrator? is false' do
        expect(user.is_project_administrator?).to be(false)
      end

      specify '#is_super_user?' do
        expect(user.is_superuser?).to be(false)
      end
    end

    context 'when administator' do
      before { user.is_administrator = true  }
      specify '#is superuser?' do
        expect(user.is_superuser?).to be true
      end
    end

    context 'when ia project administrator' do
      before {
        ProjectMember.create(project_id: $project_id, user: user, is_project_administrator: true)
      }
      specify '#is_superuser(project)?' do
        expect(user.is_superuser?(Project.find($project_id))).to be true
      end
    end
  end

  context 'with password, password confirmation and email' do
    it { should be_valid }
  end

  context 'when password is empty' do
    before { user.password = user.password_confirmation = '' }
    it { should be_invalid }
  end

  context 'when password confirmation doesn\'t match' do
    before { user.password_confirmation = 'mismatch' }
    it { should be_invalid }
  end

  context 'when password is too short' do
    before { user.password = user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  context 'when email is empty' do
    before { user.email = '' }
    it { should be_invalid }
  end

  context 'when email doesn\'t match expected format' do
    before { user.email = 'a b@c.d' }
    it { should be_invalid }
  end

  describe 'saved user' do
    before { user.save }
    context 'password is not validated on .update() when neither password and password_confirmation are provided' do
      before { user.update(email: 'abc@def.com') }
      it {should be_valid}
      specify 'without errors' do
        expect(user.errors.count).to eq(0)
      end
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password: 'Abcd123!') }
      it {should_not be_valid}
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password_confirmation: 'Abcd123!') }
      it {should_not be_valid}
    end
  end

  describe 'remember token' do
    before { user.save }
    it(:remember_token) { should_not be_blank }
  end
  
  describe 'password reset token' do
    
    it 'is nil on a newly created user' do
      expect(user.password_reset_token).to be_nil
    end
    
    describe '#generate_password_reset_token' do
      it 'records the time it was generated' do
          Timecop.freeze(DateTime.now) do
            user.generate_password_reset_token()
            expect(user.password_reset_token_date).to eq(DateTime.now)
        end
      end
    
      it 'generates a random token' do
        expect(user.generate_password_reset_token()).to_not eq(user.generate_password_reset_token())
      end
      
      it 'does not record the token in plain text' do
        token = user.generate_password_reset_token()
        expect(token).to_not eq(user.password_reset_token)
      end
      
      it 'generates the token with at least 16 chars' do
        expect(user.generate_password_reset_token).to satisfy { |v| v.length >= 16 }
      end
    end
    
    describe '#password_reset_token_matches?' do
            
      context 'valid' do
        it 'returns truthy when the supplied token matches the user''s' do
          token = user.generate_password_reset_token()
          expect(user.password_reset_token_matches?(token)).to be_truthy
        end
      end
      
      context 'invalid' do
        let(:examples) { [nil, '', 'token'] }
          
        it 'returns falsey when the user has no token' do
          user.password_reset_token = nil
          examples.each { |e| expect(user.password_reset_token_matches?(e)).to be_falsey }
        end
        
        it 'returns falsey when the supplied token does not match the user''s' do
          user.generate_password_reset_token()
          examples.each { |e| expect(user.password_reset_token_matches?(e)).to be_falsey }
        end
      end
    end
  end

end
