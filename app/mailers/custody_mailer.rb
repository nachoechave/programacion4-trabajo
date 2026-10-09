class CustodyMailer < ApplicationMailer
  def transferred(evidence:, recipient:)
    @evidence = evidence
    @recipient = recipient
    mail(to: recipient.email, subject: "Digital Custody: nueva custodia de #{evidence.code}")
  end
end
