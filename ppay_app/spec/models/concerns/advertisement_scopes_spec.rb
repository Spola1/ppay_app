# frozen_string_literal: true

# spec/models/advertisement_spec.rb

require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  describe '.algorithm' do
    subject { Advertisement.for_payment(payment).for_withdrawal.order_by_algorithm(payment.national_currency_amount) }

    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement6) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement7) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement8) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement9) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement10) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

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

      # avertisement 7 - с большим количеством одинаковых активных платежей в пределах 5%
      create_list(:payment, 10, :transferring, advertisement: advertisement7, national_currency_amount: 101)

      #advertisement 8 - с большим количеством платежей с суммой, отличной от входящего платежа более чем на 5%
      create_list(:payment, 10, :transferring, advertisement: advertisement8, national_currency_amount: 400)

      # advertisement 9 - меньше времени на подтверждение
      create_list(:payment, 8, :transferring, advertisement: advertisement9, status_changed_at: 1.day.ago)

      # advertisement 10 - больше времени на подтверждение
      create_list(:payment, 8, :transferring, advertisement: advertisement10, status_changed_at: 2.days.ago)
    end

    10.times do
      it 'returns sorted list of advertisements' do
        is_expected.to(eq([advertisement6, advertisement8, advertisement7, advertisement5, advertisement4,
                           advertisement3, advertisement2, advertisement9, advertisement10, advertisement1])
                   .or(eq([advertisement6, advertisement8, advertisement7, advertisement5, advertisement3,
                           advertisement4, advertisement2, advertisement9, advertisement10, advertisement1])))
      end
    end
  end

  # Тесты для каждоко скоупа отдельно

  describe '.order_by_transferring_and_confirming_payments' do
    subject { Advertisement.for_payment(payment).for_deposit(payment.national_currency_amount).order_by_transferring_and_confirming_payments }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    let!(:advertisement1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

    before do
      # сортировка по активным платежам
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
    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    before do
      # сортировка по активным платежам(одинаковое количество платежей в каждом объявлении, но разное количество
      # 'похожих' платежей

      # 2 похожих платежа
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 40)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 151)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 102)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 102)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 143)

      # 0 похожих платежей
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 190)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 25)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 135)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 15)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 140)

      # 1 похожий платеж
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 101)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 117)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 190)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 220)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 115)

      #добавляем объявление в котором просто больше платежей(и все они с одинаковой суммой)
      create_list(:payment, 6, :transferring, advertisement: advertisement4)

      #добавляем объявление в котором меньше платежей(и все они с одинаковой суммой)
      create_list(:payment, 2, :transferring, advertisement: advertisement5)
    end

    it 'orders advertisements by similar payments' do
      result = Advertisement.for_payment(payment)
                            .for_withdrawal.order_by_similar_payments(payment.national_currency_amount)

      expect(result).to eq([advertisement2, advertisement3, advertisement1, advertisement5, advertisement4])
    end
  end

  describe '.order_by_remaining_confirmation_time' do
    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    before do
      # сортировка по оставшемуся времени
      create(:payment, :transferring, advertisement: advertisement1, status_changed_at: 1.day.ago)
      create(:payment, :transferring, advertisement: advertisement2, status_changed_at: 2.days.ago)
      create(:payment, :transferring, advertisement: advertisement3, status_changed_at: 3.days.ago)
    end

    it 'orders advertisements by remaining confirmation time' do
      result = Advertisement.for_payment(payment).for_withdrawal.order_by_remaining_confirmation_time
      expect(result).to eq([advertisement1, advertisement2, advertisement3])
    end
  end
end
