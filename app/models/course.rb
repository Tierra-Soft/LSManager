class Course < ApplicationRecord
  has_many :lessons, -> { order(:position) }, dependent: :destroy
  has_many :student_course_enrollments, dependent: :destroy
  has_many :students, through: :student_course_enrollments

  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :title, presence: true
end
