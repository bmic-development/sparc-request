class ChangePrimaryKeyToBigintOnPricingMaps < ActiveRecord::Migration[5.0]
  def change
    change_column :pricing_maps, :id, :bigint
  end
end
