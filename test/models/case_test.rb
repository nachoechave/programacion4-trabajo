require "test_helper"

class CaseTest < ActiveSupport::TestCase
  test "code is unique" do
    Case.create!(code: "CAS-TEST-001", title: "Primer caso", status: :open, opened_at: Time.current)
    duplicate = Case.new(code: "CAS-TEST-001", title: "Segundo caso", status: :open, opened_at: Time.current)

    assert_not duplicate.valid?
    assert duplicate.errors[:code].any?
  end
end
