class ChangePrimaryKeyToBigintOnServiceRelations < ActiveRecord::Migration[5.0]
  def change
    change_column :service_relations, :id, :bigint
  end
end
