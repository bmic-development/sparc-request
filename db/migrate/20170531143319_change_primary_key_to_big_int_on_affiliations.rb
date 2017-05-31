class ChangePrimaryKeyToBigIntOnAffiliations < ActiveRecord::Migration[5.0]
  def change
    change_column :affiliations, :id, :bigint
  end
end
