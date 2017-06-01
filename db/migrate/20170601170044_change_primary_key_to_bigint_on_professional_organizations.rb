class ChangePrimaryKeyToBigintOnProfessionalOrganizations < ActiveRecord::Migration[5.0]
  def change
    change_column :professional_organizations, :id, :bigint
  end
end
