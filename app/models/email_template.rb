class EmailTemplate < ApplicationRecord
  has_many :email_logs, dependent: :nullify

  enum :category, { general: 0, welcome: 1, progress_reminder: 2, completion: 3 }

  validates :name, presence: true
  validates :subject, presence: true
  validates :body, presence: true

  def render_for(student)
    rendered_subject = subject.gsub("{{name}}", student.name)
                              .gsub("{{student_code}}", student.student_code.to_s)
    rendered_body = body.gsub("{{name}}", student.name)
                        .gsub("{{student_code}}", student.student_code.to_s)
                        .gsub("{{department}}", student.department.to_s)
    [rendered_subject, rendered_body]
  end
end
