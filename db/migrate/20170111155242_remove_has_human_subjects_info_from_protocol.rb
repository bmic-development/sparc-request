class RemoveHasHumanSubjectsInfoFromProtocol < ActiveRecord::Migration
  def up
    remove_column :protocols, :has_human_subject_info
  end

  def down
    add_column :protocols, :has_human_subject_info, :boolean
  end
end
