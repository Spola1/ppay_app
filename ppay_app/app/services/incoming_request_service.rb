class IncomingRequestService
  def initialize(incoming_request)
    @incoming_request = incoming_request
  end

  def process_request
    return unless find_matching_advertisement

    find_matching_payment

    build_related_models

    payment_message

    render_success_response
  end

  private

  def find_matching_advertisement
    search_fields = {
      'smsdeliverer' => { search_field: :imsi },
      'SMS Forwarder' => {
        'SMS' => { search_field: :phone },
        'PUSH' => { search_field: :imei }
      }
    }

    app = @incoming_request.app
    request_type = @incoming_request.request_type
    search_value = search_fields.dig(app, request_type)
    return false unless search_value

    search_field = search_value[:search_field]
    search_value = @incoming_request.send(search_field)

    @matching_advertisements = Advertisement.where("imei = :value OR imsi = :value OR phone = :value",
                                                   value: search_value, simbank_auto_confirmation: true)

    card_number_masks = Mask.where(sender: @incoming_request.from, regexp_type: 'Номер счёта')

    @advertisement = nil
    @card_mask = nil

    @matching_advertisements.each do |advertisement|
      card_number_masks.each do |mask|
        regexp = eval(mask.regexp)
        field_to_check = @incoming_request.content || @incoming_request.message
        match = field_to_check.scan(regexp).first

        @advertisement = advertisement if match.present? && match.include?(advertisement.simbank_card_number)
        @card_mask = mask if match.present? && match.include?(advertisement.simbank_card_number)
      end
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

    return unless @advertisement

    @advertisement.payments.for_simbank.each do |payment|
      amount_masks.each do |mask|
        regexp = eval(mask.regexp)
        field_to_check = @incoming_request.content || @incoming_request.message
        match = field_to_check.scan(regexp).first

        @payment = payment
        @amount_mask = mask if match.present? && match.include?(payment.decorate.national_formatted) 
        @payment.confirm! if match.present? && match.include?(payment.decorate.national_formatted)
      end
    end
  end

  def payment_message
    return unless @payment.present?

    text = "#{@incoming_request.created_at}\n"
    text += "#{@incoming_request.message}\n" if @incoming_request.message
    text += "#{@incoming_request.content}\n" if @incoming_request.content

    @incoming_request.attributes.each do |attr, value|
      next if value.nil? || %w[id created_at updated_at message content].include?(attr)

      text += "#{attr}: #{value}\n"
    end

    text += 'симбанк подтвердил подтвердил платеж согласно этому сообщению'

    @payment.comments.create!(
      author_nickname: 'SIM-банк',
      author_type: 'Processor',
      user_id: @payment.processer.id,
      text: text
    )
  end

  def render_success_response
    { status: 'success', message: 'Запрос успешно сохранен' }
  end
end