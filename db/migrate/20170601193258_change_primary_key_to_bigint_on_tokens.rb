class ChangePrimaryKeyToBigintOnTokens < ActiveRecord::Migration[5.0]
  def change
    change_column :tokens, :id, :bigint
  end
end
