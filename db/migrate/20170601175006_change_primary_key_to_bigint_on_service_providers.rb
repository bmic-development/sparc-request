class ChangePrimaryKeyToBigintOnServiceProviders < ActiveRecord::Migration[5.0]
  def change
    change_column :service_providers, :id, :bigint
  end
end
