class ChangePrimaryKeyToBigintOnSubsidies < ActiveRecord::Migration[5.0]
  def change
    change_column :subsidies, :id, :bigint
  end
end
