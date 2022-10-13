class Withdrawal < Payment
  # вывод, снятие средств со счета = операция по покупке (buy) 

  include AASM

  aasm whiny_transitions: false, column: :payment_status do
    state :draft, initial: true
    state :specifying_details, :waiting_for_processing, :confirming, :completed, :cancelled

    # здесь мы отображаем драфт платежа
    # результат действия - вывод окна, где человек вводит реквизиты карты
    event :show do
      transitions from: :draft, to: :specifying_details
    end
    
    # здесь мы по полученным реквизитам человека:
    # 1) подбираем подходящего оператора, который готов обработать этот банк
    # 2) подходящий оператор должен успеть обработать этот платёж 
    # (сделать перевод со своей карты)
    event :process do
      transitions from: :specifying_details, to: :waiting_for_processing
    end

    # здесь человек переходит на окно, где ему надо подтвердить,
    # что на его карту пришли деньги - будет соответствующая кнопка "Получил"
    event :confirm do
      transitions from: :waiting_for_processing, to: :confirming
    end

    # здесь человек нажал на кнопку "подтвердить"
    # его перекидывает на окно "вы получили оплату!"
    event :complete do
      transitions from: :confirming, to: :completed
    end


    event :cancel do
      transitions from: [:choosing_payment_system, :waiting_for_operator, :waiting_for_payment], to: :cancelled
    end
  end

end