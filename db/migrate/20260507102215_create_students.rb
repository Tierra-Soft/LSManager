class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :name
      t.string :email
      t.string :student_code
      t.string :department
      t.date :enrolled_on
      t.integer :status

      t.timestamps
    end
    add_index :students, :email, unique: true
  end
end
