class ChangePrimaryKeyToBigIntOnInvestigationalProductsInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :investigational_products_info, :id, :bigint
  end
end
