class AddStatusFieldToTransactionsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :status, :string
    # предполагаемые типы статусов:
    # заморожена
    # исполнена
    # арбитраж
    # отменена
    #
    #
  end
end
