class AddIndexPaymentsUuidTrgm < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
        execute 'CREATE INDEX idx_payments_uuid_trgm ON payments USING gin ((uuid::text) gin_trgm_ops);'
      end

      dir.down do
        execute 'DROP INDEX IF EXISTS idx_payments_uuid_trgm;'
      end
    end
  end
end
