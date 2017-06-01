class ChangePrimaryKeyToBigintOnPastSubsidies < ActiveRecord::Migration[5.0]
  def change
    change_column :past_subsidies, :id, :bigint
  end
end
