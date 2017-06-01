class ChangePrimaryKeyToBigintOnVertebrateAnimalsInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :vertebrate_animals_info, :id, :bigint
  end
end
