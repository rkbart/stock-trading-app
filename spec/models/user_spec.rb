# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:portfolio).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe 'devise modules' do
    it 'contains expected devise modules' do
      expect(User.devise_modules).to contain_exactly(
        :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable,
        :confirmable
      )
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(trader: 0, admin: 1) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending approved rejected]) }
  end

  describe 'callbacks' do
    it 'creates portfolio after creation' do
      user = create(:user)
      expect(user.portfolio).to be_present
      expect(user.portfolio.balance).to eq(0.0)
    end
  end

  describe '#balance' do
    context 'with portfolio' do
      let(:user) { create(:user, :with_portfolio) }

      it 'returns portfolio balance' do
        user.portfolio.update!(balance: 100.0)
        expect(user.balance).to eq(100.0)
      end
    end

    context 'without portfolio' do
      let(:user) { build(:user) }

      it 'returns 0' do
        expect(user.balance).to eq(0)
      end
    end
  end

  describe '#full_name' do
    let(:user) { build(:user, email: 'john.doe@example.com', last_name: 'Doe') }

    it 'generates slug from email prefix and last name' do
      expect(user.full_name).to eq('john-doe-doe')
    end
  end
end