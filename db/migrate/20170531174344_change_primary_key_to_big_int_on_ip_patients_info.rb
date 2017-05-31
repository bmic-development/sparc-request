class ChangePrimaryKeyToBigIntOnIpPatientsInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :ip_patents_info, :id, :bigint
  end
end
