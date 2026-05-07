class CreateStudentCourseEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :student_course_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.date :enrolled_on

      t.timestamps
    end
  end
end
