class WithdrawalDecorator < PaymentDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def url
    payments_withdrawal_url(uuid:, signature:)
  end
end
