class ChangePrimaryKeyToBigintOnTaggings < ActiveRecord::Migration[5.0]
  def change
    change_column :taggings, :id, :bigint
  end
end
