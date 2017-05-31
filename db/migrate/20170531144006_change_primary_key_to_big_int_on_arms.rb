class ChangePrimaryKeyToBigIntOnArms < ActiveRecord::Migration[5.0]
  def change
    change_column :arms, :id, :bigint
  end
end
