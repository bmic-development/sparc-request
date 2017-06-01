class ChangePrimaryKeyToBigintOnProtocols < ActiveRecord::Migration[5.0]
  def change
    remove_reference :submissions, :protocol, index: true, foreign_key: true
    change_column :protocols, :id, :bigint
    add_reference :submissions, :protocol, type: :bigint, index: true, foreign_key: true
  end
end
