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

  describe '.algorithm' do
    subject { Advertisement.for_payment(payment).for_deposit(payment.cryptocurrency_amount).order_by_algorithm(payment.national_currency_amount) }

    let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement6) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement7) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement8) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :deposit, :processer_search) }

    before do
      # advertisement 1 - много активный платежей в процессе с такой же суммой
      create_list(:payment, 10, :transferring, advertisement: advertisement1)

      # advertisement 2 - много активных платежей с разными суммами, в том числе с такой же
      create_list(:payment, 6, :transferring, advertisement: advertisement2)
      create_list(:payment, 6, :transferring, advertisement: advertisement2, national_currency_amount: 200)

      # advertisement 3 - много неактивных завершенных платежей с такой же суммой, но мало активных
      create_list(:payment, 20, :completed, advertisement: advertisement3)
      create_list(:payment, 4, :transferring, advertisement: advertisement3)

      # advertisement 4 - мало активных платежей с такой же суммой,
      # должно иметь такой же приоритет как и advertisement_3, так как не должно зависеть от
      # завершенных платежей, поэтому между 3 и 4 должен быть рандомный результат
      create_list(:payment, 4, :transferring, advertisement: advertisement4)

      # advertisement 5 - мало активных платежей с такой же суммой
      # и мало платежей transferring с такой же суммой на арбитраже,
      # но много платежей confirming с такой же суммой на арбитраже

      create_list(:payment, 1, :transferring, advertisement: advertisement5)
      create_list(:payment, 1, :transferring, advertisement: advertisement5, arbitration: true)
      create_list(:payment, 10, :confirming, advertisement: advertisement5, arbitration: true)

      # advertisement 6 - без платежей вообще

      create_list(:payment, 5, :confirming, advertisement: advertisement7, status_changed_at: Time.now - 15.minutes)

      create_list(:payment, 6, :confirming, advertisement: advertisement8, status_changed_at: Time.now - 6.minutes)
    end

    10.times do
      it 'returns sorted list of advertisements' do
        is_expected.to(eq([advertisement6, advertisement5, advertisement4,
                           advertisement3, advertisement7, advertisement8, advertisement2, advertisement1])
                   .or(eq([advertisement6, advertisement5, advertisement3,
                           advertisement4, advertisement7, advertisement8, advertisement2, advertisement1])))
      end
    end
  end
end
