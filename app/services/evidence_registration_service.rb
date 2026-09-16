class EvidenceRegistrationService
  def self.call(evidence:, performed_by:)
    new(evidence:, performed_by:).call
  end

  def initialize(evidence:, performed_by:)
    @evidence = evidence
    @performed_by = performed_by
  end

  def call
    Evidence.transaction do
      evidence.save!
      evidence.custody_movements.create!(
        from_user: nil,
        to_user: evidence.current_custodian,
        performed_by: performed_by,
        transferred_at: Time.current,
        reason: "Registro inicial"
      )
    end

    evidence
  end

  private

  attr_reader :evidence, :performed_by
end
