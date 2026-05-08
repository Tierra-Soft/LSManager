class EmailTemplate < ApplicationRecord
  has_many :email_logs, dependent: :nullify

  enum :category, { general: 0, welcome: 1, progress_reminder: 2, completion: 3 }

  validates :name, presence: true
  validates :subject, presence: true
  validates :body, presence: true

  def render_for(student)
    replacements = {
      "{{name}}"         => student.name.to_s,
      "{{student_code}}" => student.reception_number.to_s,
      "{{department}}"   => student.affiliated_association.to_s
    }
    rendered_subject = replacements.reduce(subject) { |s, (k, v)| s.gsub(k, v) }
    rendered_body    = replacements.reduce(body)    { |s, (k, v)| s.gsub(k, v) }
    [rendered_subject, rendered_body]
  end
end
