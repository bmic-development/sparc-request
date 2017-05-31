class ChangePrimaryKeyToBigIntOnClinicalProviders < ActiveRecord::Migration[5.0]
  def change
    change_column :clinical_providers, :id, :bigint
  end
end
