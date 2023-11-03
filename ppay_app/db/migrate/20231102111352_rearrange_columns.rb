class RearrangeColumns < ActiveRecord::Migration[7.0]
  def rearrange_columns(table_name, schemarb)
    columns = schemarb.split("\n").map { _1.match(/t\.(?<type>\w+)\s+"(?<name>.*?)"(,\s+(?<arguments>.*))?/) }

    columns.each do |column|
      add_column table_name, "tmp_#{column[:name]}", column[:type], **eval("{#{column[:arguments]}}")
    end

    sql = "UPDATE #{table_name} SET "
    columns.each do |column|
      sql << "tmp_#{column[:name]} = #{column[:name]}, "
    end
    sql.chomp!(', ')
    sql << ';'
    execute sql

    columns.each do |column|
      remove_column table_name, column[:name]
      rename_column table_name, "tmp_#{column[:name]}", column[:name]
    end
  end

  def up
    return unless Rails.env.development? || Rails.env.test?

    rearrange_columns(
      :advertisements,
      <<~SCHEMARB
        t.decimal "conversion", default: "0.0"
        t.integer "completed_payments", default: 0
        t.integer "cancelled_payments", default: 0
        t.string "telegram_phone"
      SCHEMARB
    )

    rearrange_columns(
      :payments,
      <<~SCHEMARB
        t.decimal "initial_amount", precision: 128, scale: 64
        t.integer "processing_type", default: 0
        t.string "locale"
        t.integer "arbitration_reason"
        t.boolean "autoconfirming", default: false
        t.string "account_number"
        t.bigint "form_customization_id"
        t.integer "advertisement_not_found_reason"
        t.decimal "adjusted_rate"
        t.string "other_processing_id"
      SCHEMARB
    )

    rearrange_columns(
      :users,
      <<~SCHEMARB
        t.decimal "processer_withdrawal_commission", precision: 15, scale: 10, default: "1.0"
        t.decimal "working_group_withdrawal_commission", precision: 15, scale: 10, default: "1.0"
        t.boolean "only_whitelisted_processers", default: false, null: false
        t.integer "equal_amount_payments_limit"
        t.decimal "fee_percentage", precision: 5, scale: 2, default: "0.0"
        t.integer "short_freeze_days"
        t.integer "long_freeze_days"
        t.decimal "long_freeze_percentage", precision: 5, scale: 2
        t.integer "balance_freeze_type", default: 0
        t.string "otp_secret"
        t.integer "consumed_timestep"
        t.boolean "otp_required_for_login"
        t.boolean "otp_payment_confirm"
        t.boolean "can_edit_summ"
      SCHEMARB
    )

    add_index :payments, ['arbitration_reason'], name: 'index_payments_on_arbitration_reason'
    add_index :payments, ['form_customization_id'], name: 'index_payments_on_form_customization_id'
    add_foreign_key 'payments', 'form_customizations'
  end
end
