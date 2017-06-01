class ChangePrimaryKeyToBigintOnPricingSetups < ActiveRecord::Migration[5.0]
  def change
    change_column :pricing_setups, :id, :bigint
  end
end
