class ChangePrimaryKeyToBigIntOnAudits < ActiveRecord::Migration[5.0]
  def change
    change_column :audits, :id, :bigint
  end
end
