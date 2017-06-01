class ChangePrimaryKeyToBigintOnResearchTypesInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :research_types_info, :id, :bigint
  end
end
