# spec/models/holding_spec.rb
require 'rails_helper'

RSpec.describe Holding, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:portfolio) }
    it { is_expected.to belong_to(:stock) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe '#value' do
    let(:stock) { create(:stock, last_price: 50.00) }
    let(:holding) { create(:holding, stock: stock, shares: 10) }

    it 'calculates value as shares multiplied by stock price' do
      expect(holding.value).to eq(500.00) # 10 shares * $50
    end
  end

  describe 'average_price' do
    context 'with shares' do
      let(:holding) { create(:holding, shares: 10, total: 1000.00) }

      it 'calculates average price per share' do
        expect(holding.average_price).to eq(100.00) # $1000 / 10 shares
      end
    end

    context 'with zero shares' do
      let(:holding) { create(:holding, shares: 0, total: 1000.00) }

      it 'returns 0' do
        expect(holding.average_price).to eq(0)
      end
    end
  end
end