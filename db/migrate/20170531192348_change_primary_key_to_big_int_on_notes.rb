class ChangePrimaryKeyToBigIntOnNotes < ActiveRecord::Migration[5.0]
  def change
    change_column :notes, :id, :bigint
  end
end
