# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditsHelper, type: :helper do
  describe '#formatted_changes' do
    subject { formatted_changes(attribute, values) }

    let(:attribute) { 'payment_status' }

    context 'values is an array' do
      let(:values) { %w[transferring confirming] }

      it 'returns elements joined with " -> "' do
        expect(subject).to eq(values.join(' -> '))
      end
    end

    context 'values is not an array' do
      let(:values) { 'created' }

      it 'returns its content' do
        expect(subject).to eq values
      end
    end

    context 'attribute is "status_changed_at"' do
      let(:attribute) { 'status_changed_at' }

      context 'values is single string' do
        let(:values) { '2023-02-02TO2:46:30.352+03:00' }

        it 'returns formatted datetime' do
          expect(subject).to eq('2023-02-02 02:46:30')
        end
      end

      context 'values is an array' do
        let(:values) { ['2023-02-02TO2:46:30.352+03:00', '2023-02-13T19:59:17.202+03:00'] }

        it 'returns formatted datetimes' do
          expect(subject).to eq('2023-02-02 02:46:30 -> 2023-02-13 19:59:17')
        end
      end
    end
  end

  describe '#formatted_date_string' do
    let(:date) { '2023-02-02TO2:46:30.352+03:00' }
    subject { formatted_date_string(date) }

    it 'formats date correctly' do
      expect(subject).to eq('2023-02-02 02:46:30')
    end
  end
end
