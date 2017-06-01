class ChangePrimaryKeyToBigintOnRevenueCodeRanges < ActiveRecord::Migration[5.0]
  def change
    change_column :revenue_code_ranges, :id, :bigint
  end
end
