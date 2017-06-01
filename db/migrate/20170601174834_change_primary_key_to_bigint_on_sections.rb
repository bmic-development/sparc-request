class ChangePrimaryKeyToBigintOnSections < ActiveRecord::Migration[5.0]
  def change
    remove_reference :questions, :section, index: true, foreign_key: true
    change_column :sections, :id, :bigint
    add_reference :questions, :section, type: :bigint, index: true, foreign_key: true
  end
end
