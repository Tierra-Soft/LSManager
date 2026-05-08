class ScheduledEmailJob < ApplicationJob
  queue_as :default

  def perform(email_log_id)
    log = EmailLog.find(email_log_id)
    subject, body = log.email_template.render_for(log.student)
    mail = StudentMailer.template_email(log.student, subject, body)
    mail.deliver_now
    log.update!(status: :sent, sent_at: Time.current, raw_message: mail.to_s)
  rescue => e
    EmailLog.find_by(id: email_log_id)&.update!(status: :failed, error_message: e.message, sent_at: Time.current)
    raise
  end
end
