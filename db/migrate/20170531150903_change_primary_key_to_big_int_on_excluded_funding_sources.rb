class ChangePrimaryKeyToBigIntOnExcludedFundingSources < ActiveRecord::Migration[5.0]
  def change
    change_column :excluded_funding_sources, :id, :bigint
  end
end
