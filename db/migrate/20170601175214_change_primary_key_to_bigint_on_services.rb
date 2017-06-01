class ChangePrimaryKeyToBigintOnServices < ActiveRecord::Migration[5.0]
  def change
    remove_reference :submissions, :service, index: true, foreign_key: true
    remove_reference :questionnaires, :service, index: true, foreign_key: true
    change_column :services, :id, :bigint
    add_reference :submissions, :service, type: :bigint, index: true, foreign_key: true
    add_reference :questionnaires, :service, type: :bigint, index: true, foreign_key: true
  end
end
