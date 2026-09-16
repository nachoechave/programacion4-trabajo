require "test_helper"

class EvidenceTransferServiceTest < ActiveSupport::TestCase
  setup do
    @admin = create_user("Administrador", "transfer-admin@example.com", :admin)
    @juan = create_user("Juan Pérez", "transfer-juan@example.com", :analyst)
    @maria = create_user("María López", "transfer-maria@example.com", :analyst)
    @case = Case.create!(code: "CAS-TRANSFER", title: "Caso de transferencia", status: :open, opened_at: Time.current)
    @type = EvidenceType.create!(name: "Disco de prueba")
    @evidence = Evidence.create!(
      code: "EVD-TRANSFER",
      name: "Disco",
      case: @case,
      evidence_type: @type,
      current_custodian: @juan,
      status: :in_custody,
      collected_at: Time.current
    )
  end

  test "valid transfer creates a custody movement" do
    assert_difference("CustodyMovement.count", 1) { perform_transfer }
  end

  test "valid transfer changes current custodian" do
    perform_transfer

    assert_equal @maria, @evidence.reload.current_custodian
  end

  test "movement keeps previous custodian as from user" do
    perform_transfer

    assert_equal @juan, @evidence.custody_movements.last.from_user
  end

  test "movement records new custodian as to user" do
    perform_transfer

    assert_equal @maria, @evidence.custody_movements.last.to_user
  end

  test "rejects transfer to current custodian" do
    error = assert_raises(EvidenceTransferService::TransferError) do
      EvidenceTransferService.call(
        evidence: @evidence,
        to_user: @juan,
        reason: "Sin cambio",
        performed_by: @admin
      )
    end

    assert_equal "La evidencia ya pertenece a ese custodio", error.message
    assert_equal @juan, @evidence.reload.current_custodian
  end

  test "rejects transfer when case is closed" do
    @case.closed!

    assert_raises(EvidenceTransferService::TransferError) { perform_transfer }
    assert_equal @juan, @evidence.reload.current_custodian
  end

  test "rolls back custodian change when movement creation fails" do
    association = @evidence.custody_movements
    invalid_movement = CustodyMovement.new
    invalid_movement.errors.add(:base, "Falla simulada")
    association.define_singleton_method(:create!) do |**|
      raise ActiveRecord::RecordInvalid, invalid_movement
    end

    assert_raises(ActiveRecord::RecordInvalid) { perform_transfer }

    assert_equal @juan, @evidence.reload.current_custodian
    assert_equal 0, @evidence.custody_movements.count
  end

  private

  def create_user(name, email, role)
    User.create!(name:, email:, password: "password123", role:, active: true)
  end

  def perform_transfer
    EvidenceTransferService.call(
      evidence: @evidence,
      to_user: @maria,
      reason: "Traslado para análisis",
      notes: "Entrega en laboratorio",
      performed_by: @admin
    )
  end
end
