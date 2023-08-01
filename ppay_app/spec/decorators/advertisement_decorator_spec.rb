# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvertisementDecorator do
  let(:advertisement) { create :advertisement, :deposit }

  describe '#card_info' do
    context 'when payment_system is less than or equal to 8 characters' do
      it 'Should return the correct card_info' do
        expect(advertisement.decorate.card_info).to eq('SBERBANK**1111')
      end
    end

    context 'when payment_system is greater than 8 characters' do
      before do
        advertisement.payment_system = 'Dushanbe City - КортиМилли'
      end

      it 'Should return the correct card_info' do
        expect(advertisement.decorate.card_info).to eq('DUSHANBE**1111')
      end
    end
  end
end
