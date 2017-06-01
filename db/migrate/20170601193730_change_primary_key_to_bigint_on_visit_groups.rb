class ChangePrimaryKeyToBigintOnVisitGroups < ActiveRecord::Migration[5.0]
  def change
    change_column :visit_groups, :id, :bigint
  end
end
