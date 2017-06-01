class ChangePrimaryKeyToBigintOnTags < ActiveRecord::Migration[5.0]
  def change
    change_column :tags, :id, :bigint
  end
end
