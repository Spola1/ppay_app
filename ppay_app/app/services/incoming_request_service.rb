# frozen_string_literal: true

class IncomingRequestService
  def initialize(incoming_request)
    @processer = incoming_request.user.becomes(Processer)
    @incoming_request = incoming_request
  end

  def process_request
    if @processer
      find_matching_advertisement
      find_matching_payment
      create_not_found_payment
      build_related_models
      payment_message
      render_success_response
    end
  end

  private

  def find_matching_advertisement
    search_fields = {
      'smsdeliverer' => {
        'SMS' => { search_field: :imsi }
      },
      'SMS Forwarder' => {
        'SMS' => { search_field: :phone },
        'PUSH' => { search_field: :imei }
      },
      'MacroDroid' => {
        'SMS' => { search_field: :phone },
        'PUSH' => { search_field: :imei }
      },
    }

    app = @incoming_request.app
    request_type = @incoming_request.request_type
    search_value = search_fields.dig(app, request_type)
    return false unless search_value

    search_field = search_value[:search_field]
    search_value = @incoming_request.send(search_field)

    @matching_advertisements = @processer.advertisements
                                         .where('imei = :value OR imsi = :value OR phone = :value',
                                                value: search_value, simbank_auto_confirmation: true,
                                                simbank_sender: @incoming_request.from)

    card_number_masks = Mask.where(sender: @incoming_request.from, regexp_type: 'Номер счёта')

    @advertisement = nil
    @card_mask = nil
    @card_number = nil

    card_number_masks.each do |mask|
      regexp = eval(mask.regexp)
      match = @incoming_request.message.scan(regexp).first

      next unless match.present?

      @advertisement = @matching_advertisements
                         .where("RIGHT(card_number, 4) = :match OR simbank_card_number = :match", match:)
                         .last
      @card_mask = mask
      @card_number = match.first

      break
    end
  end

  def build_related_models
    @incoming_request.advertisement = @advertisement if @advertisement.present?
    @incoming_request.payment = @payment if @payment.present?
    @incoming_request.card_mask = @card_mask if @card_mask.present?
    @incoming_request.sum_mask = @amount_mask if @amount_mask.present?

    @incoming_request.save
  end

  def find_matching_payment
    amount_masks = Mask.where(sender: @incoming_request.from, regexp_type: 'Сумма')

    @payment = nil
    @amount_mask = nil
    @amount = nil

    if @advertisement.present?
      find_payment_by_amount(@advertisement, amount_masks)
    else
      @matching_advertisements.where(simbank_card_number: [nil, '']).each do |advertisement|
        find_payment_by_amount(advertisement, amount_masks)
      end
    end
  end

  def find_payment_by_amount(advertisement, amount_masks)
    @advertisement = advertisement

    @advertisement.payments.for_simbank.each do |payment|
      amount_masks.each do |mask|
        regexp = eval(mask.regexp)
        match = @incoming_request.message.scan(regexp).first

        @amount = match.first.to_d

        next unless match.present? && sum_matched?(payment, match)

        @payment = payment
        @amount_mask = mask
        @payment.confirm!

        break
      end

      break if @payment
    end
  end

  def payment_message
    return unless @payment.present?

    text = "#{@incoming_request.message}\n\n"

    @incoming_request.attributes.each do |attr, value|
      next if value.nil? || %w[id created_at updated_at message content initial_params api_key payment_id
                               advertisement_id sum_mask_id card_mask_id user_id].include?(attr)

      text += "#{attr}: #{value}\n"
    end

    text += "\nсимбанк подтвердил подтвердил платеж согласно этому сообщению"

    @payment.comments.create!(
      author_nickname: Settings.simbank_nickname,
      user_id: @payment.processer.id,
      text:
    )
  end

  def sum_matched?(payment, match)
    match.first.to_d == payment.national_currency_amount.to_d
  end

  def render_success_response
    { status: 'success', message: 'Запрос успешно сохранен' }
  end

  def create_not_found_payment
    return if @advertisement.nil? || @payment.present?

    not_found_payment = NotFoundPayment.create(
      advertisement: @advertisement,
      incoming_request: @incoming_request,
      parsed_amount: @amount,
      parsed_card_number: @card_number
    )

    if @advertisement.payments.for_simbank.present?
      not_found_payment.payments << @advertisement.payments.for_simbank
    end

    not_found_payment.save!
  end
end
