require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Devise modules' do
    let(:devise_modules) { User.devise_modules }

    it { expect(devise_modules).to include(:database_authenticatable) }
    it { expect(devise_modules).to include(:registerable) }
    it { expect(devise_modules).to include(:recoverable) }
    it { expect(devise_modules).to include(:rememberable) }
    it { expect(devise_modules).to include(:validatable) }
    it { expect(devise_modules).to include(:confirmable) }
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_one(:portfolio).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(trader: 0, admin: 1) }
  end

  describe 'callbacks' do
    it 'creates a portfolio after user creation' do
      user = create(:user)
      expect(user.portfolio).to be_present
      expect(user.portfolio.balance).to eq(0.0)
    end
  end

  describe '#balance' do
    it 'returns portfolio balance' do
      user = create(:user)
      user.portfolio.update(balance: 123.45)
      expect(user.balance).to eq(123.45)
    end

    it 'returns 0 if no portfolio' do
      user = build(:user)
      expect(user.balance).to eq(0)
    end
  end

   describe '#full_name' do
    it 'returns a parameterized string of email prefix and last name' do
      user = build(:user, email: 'juan.dela@example.com', last_name: 'Cruz')
      expect(user.full_name).to eq('juan-dela-cruz')
    end
  end
end
