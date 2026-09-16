require "test_helper"

class AdminCheckpointFlowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      name: "Administrador",
      email: "flow-admin@example.com",
      password: "password123",
      role: :admin,
      active: true
    )
    @juan = User.create!(name: "Juan", email: "flow-juan@example.com", password: "password123", role: :analyst)
    @maria = User.create!(name: "María", email: "flow-maria@example.com", password: "password123", role: :analyst)
    case_record = Case.create!(code: "CAS-FLOW", title: "Flujo completo", status: :open, opened_at: Time.current)
    type = EvidenceType.create!(name: "Tipo para flujo")
    @evidence = Evidence.new(
      code: "EVD-FLOW",
      name: "Evidencia del flujo",
      case: case_record,
      evidence_type: type,
      current_custodian: @juan,
      status: :in_custody,
      collected_at: Time.current
    )
    EvidenceRegistrationService.call(evidence: @evidence, performed_by: @admin)
  end

  test "admin logs in and transfers evidence" do
    post admin_login_path, params: { email: @admin.email, password: "password123" }
    assert_redirected_to admin_root_path

    post admin_evidence_transfers_path(@evidence), params: {
      transfer: { to_user_id: @maria.id, reason: "Traslado para análisis", notes: "Demo" }
    }

    assert_redirected_to admin_evidence_path(@evidence)
    assert_equal @maria, @evidence.reload.current_custodian
    assert_equal 2, @evidence.custody_movements.count
  end

  test "anonymous visitor is redirected to login" do
    get admin_root_path

    assert_redirected_to admin_login_path
  end
end
