# frozen_string_literal: true

# spec/models/advertisement_spec.rb

require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  describe '.order_by_transferring_and_confirming_payments' do
    subject { Advertisement.order_by_transferring_and_confirming_payments }

    let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

    before do
      create_list(:payment, 2, payment_status: 'confirming', advertisement: advertisement1)
      create_list(:payment, 3, payment_status: 'transferring', advertisement: advertisement1)

      create_list(:payment, 3, payment_status: 'transferring', advertisement: advertisement2)
      create_list(:payment, 1, payment_status: 'confirming', advertisement: advertisement2)

      create_list(:payment, 2, payment_status: 'transferring', advertisement: advertisement3)
    end

    it 'orders advertisements by the count of transferring and confirming payments' do
      expect(subject).to eq([advertisement3, advertisement2, advertisement1])
    end
  end

  describe '.order_by_similar_payments' do
    context 'when < 5%' do
      let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:payment1) { create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 400) }
      let!(:payment2) { create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 600) }

      it 'orders advertisements by similar payments' do
        expect(Advertisement.order_by_similar_payments(599)).to eq([advertisement1, advertisement2])
      end
    end

    context 'when < 5% && arbitration: true' do
      let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:payment1) do
        create(:payment, :confirming, advertisement: advertisement1, national_currency_amount: 400, arbitration: true)
      end
      let!(:payment2) { create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 600) }

      it 'orders advertisements by similar payments' do
        expect(Advertisement.order_by_similar_payments(401)).to eq([advertisement2, advertisement1])
      end
    end
  end

  describe '.order_by_similar_payments_count' do
    let(:national_currency_amount) { 100 }

    let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

    before do
      # Создаем платежи, которые должны подходить под условиe (больше чем у такого же второго объявления)
      create_list(:payment, 3, national_currency_amount: 99, advertisement: advertisement3)
      create_list(:payment, 5, national_currency_amount: 101, advertisement: advertisement3)

      # Создаем платежи, которые должны подходить под условие
      create_list(:payment, 1, national_currency_amount: 99, advertisement: advertisement2)
      create_list(:payment, 4, national_currency_amount: 101, advertisement: advertisement2)

      # Создаем платежи, которые не подходят под условие
      create_list(:payment, 3, national_currency_amount: 70, advertisement: advertisement1)
      create_list(:payment, 1, national_currency_amount: 130, advertisement: advertisement1)
    end

    it 'orders advertisements by the count of similar payments' do
      advertisements = Advertisement.order_by_similar_payments_count(national_currency_amount)
      expect(advertisements).to eq([advertisement1, advertisement2, advertisement3])
    end
  end

  describe '.order_by_remaining_confirmation_time' do
    subject { Advertisement.order_by_remaining_confirmation_time }

    let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

    before do
      # Создаем платежи, которые должны учитываться в скоупе
      create(:payment, :confirming, status_changed_at: Time.current - 10.minutes, advertisement: advertisement1)
      create(:payment, :confirming, status_changed_at: Time.current - 15.minutes, advertisement: advertisement2)
      create(:payment, :confirming, status_changed_at: Time.current - 19.minutes, advertisement: advertisement3)
    end

    it 'orders advertisements by the remaining confirmation time' do
      expect(subject).to eq([advertisement1, advertisement2, advertisement3])
    end
  end
end
