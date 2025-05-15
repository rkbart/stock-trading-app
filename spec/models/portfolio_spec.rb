# spec/models/portfolio_spec.rb
require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:holdings).dependent(:destroy) }
  end

  describe '#total_value' do
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user) }
    let(:stock) { create(:stock, last_price: 100.00) }

    context 'with holdings' do
      before do
        create(:holding, portfolio: portfolio, stock: stock, shares: 10)
        create(:holding, portfolio: portfolio, stock: stock, shares: 5)
      end

      it 'returns sum of all holding values' do
        # 10 shares * $100 + 5 shares * $100 = $1500
        expect(portfolio.total_value).to eq(1500.00)
      end
    end

    context 'without holdings' do
      it 'returns 0' do
        expect(portfolio.total_value).to eq(0)
      end
    end
  end
end
