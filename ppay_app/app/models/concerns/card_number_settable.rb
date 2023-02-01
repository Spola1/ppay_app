module CardNumberSettable
  extend ActiveSupport::Concern

  included do
    def card_number=(value)
      super(value.tr('^0-9', ''))
    end
  end
end
