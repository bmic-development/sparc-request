class ChangePrimaryKeyToBigintOnSubsidyMaps < ActiveRecord::Migration[5.0]
  def change
    change_column :subsidy_maps, :id, :bigint
  end
end
