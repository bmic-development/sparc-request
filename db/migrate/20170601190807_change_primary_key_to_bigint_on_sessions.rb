class ChangePrimaryKeyToBigintOnSessions < ActiveRecord::Migration[5.0]
  def change
    change_column :sessions, :id, :bigint
  end
end
