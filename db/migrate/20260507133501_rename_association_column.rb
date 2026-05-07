class RenameAssociationColumn < ActiveRecord::Migration[8.1]
  def change
    rename_column :students, :association, :affiliated_association
  end
end
