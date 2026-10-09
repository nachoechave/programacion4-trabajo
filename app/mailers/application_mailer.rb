class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "digitalcustody@example.com")
end
