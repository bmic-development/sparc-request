class ChangePrimaryKeyToBigintOnVisits < ActiveRecord::Migration[5.0]
  def change
    change_column :visits, :id, :bigint
  end
end
