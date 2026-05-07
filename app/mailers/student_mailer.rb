class StudentMailer < ApplicationMailer
  def template_email(student, subject, body)
    @student = student
    @body = body
    mail(to: student.email, subject: subject)
  end
end
