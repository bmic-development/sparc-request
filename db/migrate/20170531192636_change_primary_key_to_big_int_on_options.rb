class ChangePrimaryKeyToBigIntOnOptions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :questions, :option, index: true, foreign_key: true
    change_column :options, :id, :bigint
    add_reference :questions, :option, type: :bigint, index: true, foreign_key: true
  end
end
