class ChangePrimaryKeyToBigintOnSuperUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :super_users, :id, :bigint
  end
end
