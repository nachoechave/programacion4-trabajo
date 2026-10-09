class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "digitalcustody@example.com")
  layout "mailer"
end
