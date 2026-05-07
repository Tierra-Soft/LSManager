class Student < ApplicationRecord
  has_many :student_course_enrollments, dependent: :destroy
  has_many :courses, through: :student_course_enrollments
  has_many :progresses, dependent: :destroy
  has_many :email_logs, dependent: :destroy

  enum :status, { active: 0, inactive: 1, completed: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :student_code, presence: true, uniqueness: true

  def self.import_csv(file)
    errors = []
    imported = 0

    CSV.foreach(file.path, headers: true, encoding: "UTF-8") do |row|
      student = find_or_initialize_by(email: row["email"])
      student.assign_attributes(
        name: row["name"],
        student_code: row["student_code"],
        department: row["department"],
        enrolled_on: row["enrolled_on"],
        status: row["status"].presence || "active"
      )
      if student.save
        imported += 1
      else
        errors << "行 #{$.}: #{student.errors.full_messages.join(', ')}"
      end
    end

    { imported: imported, errors: errors }
  rescue CSV::MalformedCSVError => e
    { imported: 0, errors: ["CSVフォーマットエラー: #{e.message}"] }
  end
end
