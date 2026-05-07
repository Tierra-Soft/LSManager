class CreateProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :progresses do |t|
      t.references :student, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
