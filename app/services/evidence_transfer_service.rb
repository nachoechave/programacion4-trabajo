class EvidenceTransferService
  class TransferError < StandardError; end

  def self.call(evidence:, to_user:, reason:, notes: nil, performed_by:)
    new(evidence:, to_user:, reason:, notes:, performed_by:).call
  end

  def initialize(evidence:, to_user:, reason:, notes:, performed_by:)
    @evidence = evidence
    @to_user = to_user
    @reason = reason.to_s.strip
    @notes = notes
    @performed_by = performed_by
  end

  def call
    validate_transfer!
    from_user = evidence.current_custodian

    ActiveRecord::Base.transaction do
      evidence.update!(current_custodian: to_user)
      evidence.custody_movements.create!(
        from_user:,
        to_user:,
        performed_by:,
        transferred_at: Time.current,
        reason:,
        notes:
      )
    end

    evidence
  end

  private

  attr_reader :evidence, :to_user, :reason, :notes, :performed_by

  def validate_transfer!
    raise TransferError, "La evidencia debe existir" unless evidence&.persisted?
    raise TransferError, "El nuevo custodio debe existir" unless to_user&.persisted?
    raise TransferError, "El usuario que realiza la transferencia debe existir" unless performed_by&.persisted?
    raise TransferError, "El motivo es obligatorio" if reason.blank?
    raise TransferError, "La evidencia ya pertenece a ese custodio" if evidence.current_custodian == to_user
    raise TransferError, "No se puede transferir evidencia de un caso cerrado" if evidence.case.closed?
    raise TransferError, "El nuevo custodio debe estar activo" unless to_user.active?
  end
end
