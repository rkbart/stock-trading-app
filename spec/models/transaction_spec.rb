# spec/models/transaction_spec.rb
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { create(:user) }
  let(:portfolio) { create(:portfolio, user: user) }
  let(:stock) { create(:stock) }
  let(:holding) { create(:holding, portfolio: portfolio, stock: stock) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:holding).optional }
  end

  describe 'scopes' do
    describe '.recent_first' do
      let!(:transaction1) { create(:transaction, transaction_date: 1.day.ago, user: user) }
      let!(:transaction2) { create(:transaction, transaction_date: Time.current, user: user) }
      let!(:transaction3) { create(:transaction, transaction_date: 2.days.ago, user: user) }

      it 'orders transactions by most recent first' do
        expect(Transaction.recent_first).to eq([transaction2, transaction1, transaction3])
      end
    end
  end

  describe 'validations' do
    context 'for buy/sell transactions' do
      let(:transaction) { build(:transaction, :buy, user: user, holding: holding) }

      it 'requires quantity' do
        transaction.quantity = nil
        expect(transaction).not_to be_valid
      end

      it 'requires quantity to be greater than 0' do
        transaction.quantity = 0
        expect(transaction).not_to be_valid
      end
    end
  end

  describe '#requires_quantity?' do
    context 'when transaction_type is buy or sell' do
      it 'returns true for buy' do
        transaction = build(:transaction, :buy, user: user, holding: holding)
        expect(transaction.requires_quantity?).to be true
      end

      it 'returns true for sell' do
        transaction = build(:transaction, :sell, user: user, holding: holding)
        expect(transaction.requires_quantity?).to be true
      end
    end
  end
end