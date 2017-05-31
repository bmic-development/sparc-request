class ChangePrimaryKeyToBigIntOnImpactAreas < ActiveRecord::Migration[5.0]
  def change
    change_column :impact_areas, :id, :bigint
  end
end
