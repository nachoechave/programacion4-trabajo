require "test_helper"

class EvidenceTest < ActiveSupport::TestCase
  test "code is unique" do
    analyst = User.create!(name: "Analista", email: "evidence-analyst@example.com", password: "password123", role: :analyst)
    case_record = Case.create!(code: "CAS-EVIDENCE", title: "Caso", status: :open, opened_at: Time.current)
    type = EvidenceType.create!(name: "Tipo de prueba")
    attributes = {
      code: "EVD-TEST-001",
      name: "Evidencia",
      case: case_record,
      evidence_type: type,
      current_custodian: analyst,
      status: :registered,
      collected_at: Time.current
    }
    Evidence.create!(attributes)
    duplicate = Evidence.new(attributes.merge(name: "Duplicada"))

    assert_not duplicate.valid?
    assert duplicate.errors[:code].any?
  end
end
