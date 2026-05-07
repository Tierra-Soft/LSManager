class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.action_mailer.default_options&.dig(:from) || "noreply@example.com"
  layout "mailer"
end
