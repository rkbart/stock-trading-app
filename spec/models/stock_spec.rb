# spec/models/stock_spec.rb
require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:holdings) }
  end

  describe '#current_price' do
    context 'when last_price is present' do
      let(:stock) { create(:stock, last_price: 150.75) }

      it 'returns the last_price' do
        expect(stock.current_price).to eq(150.75)
      end
    end

    context 'when last_price is nil' do
      let(:stock) { create(:stock, last_price: nil) }

      it 'returns 0' do
        expect(stock.current_price).to eq(0)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid stock' do
      stock = build(:stock)
      expect(stock).to be_valid
    end
  end
end