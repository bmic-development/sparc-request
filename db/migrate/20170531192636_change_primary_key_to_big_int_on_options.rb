class ChangePrimaryKeyToBigIntOnOptions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :questions, :depender, foreign_key: {to_table: :options}
    change_column :options, :id, :bigint
    add_reference :questions, :depender, type: :bigint, foreign_key: {to_table: :options}
  end
end
