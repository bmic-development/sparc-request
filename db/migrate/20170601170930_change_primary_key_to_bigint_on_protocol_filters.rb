class ChangePrimaryKeyToBigintOnProtocolFilters < ActiveRecord::Migration[5.0]
  def change
    change_column :protocol_filters, :id, :bigint
  end
end
