require 'rails_helper'

RSpec.describe AuditsHelper, type: :helper do
  describe '#formatted_changes' do
    subject { formatted_changes(attribute, values) }

    context 'when attribute is not "status_changed_at"' do
      let(:attribute) { 'payment_status' }
      let(:values) { ['transferring', 'confirming'] }

      it 'returns values joined with " -> "' do
        expect(subject).to eq('transferring -> confirming')
      end
    end

    context 'when attribute is "status_changed_at"' do
      let(:attribute) { 'status_changed_at' }
      let(:values) { ['2023-02-02TO2:46:30.352+03:00', '2023-02-13T19:59:17.202+03:00'] }

      it 'returns formatted values joined with " -> "' do
        expect(subject).to eq('2023-02-02 02:46 -> 2023-02-13 19:59')
      end
    end
  end

  describe '#formatted_date_string' do
    let(:date) { '2023-02-02TO2:46:30.352+03:00' }
    subject { formatted_date_string(date) }

    it 'formats date correctly' do
      expect(subject).to eq('2023-02-02 02:46')
    end
  end

  describe '#verify_array' do
    context 'when values is an array and attribute is "status_changed_at"' do
      let(:attribute) { 'status_changed_at' }
      let(:values) { ['2023-02-02TO2:46:30.352+03:00', '2023-02-13T19:59:17.202+03:00'] }

      it 'returns formatted changes' do
        expect(helper.verify_array(attribute, values)).to eq('2023-02-02 02:46 -> 2023-02-13 19:59')
      end
    end

    context 'when values is an array and attribute is not "status_changed_at"' do
      let(:attribute) { 'payment_status' }
      let(:values) { ['transferring', 'confirming'] }

      it 'returns formatted changes' do
        expect(helper.verify_array(attribute, values)).to eq('transferring -> confirming')
      end
    end

    context 'when values is not an array' do
      let(:attribute) { 'national_currency' }
      let(:values) { 'RUB' }

      it 'returns the original value' do
        expect(helper.verify_array(attribute, values)).to eq('RUB')
      end
    end
  end
end