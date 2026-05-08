class AddScoreToLessonsAndProgresses < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :total_score, :integer, default: 100, null: false
    add_column :progresses, :score, :integer, default: 0, null: false
  end
end
