class ChangePrimaryKeyToBigintOnToastMessages < ActiveRecord::Migration[5.0]
  def change
    change_column :toast_messages, :id, :bigint
  end
end
