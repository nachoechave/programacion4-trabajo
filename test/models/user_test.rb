require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email" do
    user = User.new(name: "Sin Email", password: "password123", role: :analyst)

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email is unique regardless of capitalization" do
    User.create!(name: "Juan", email: "juan@example.com", password: "password123", role: :analyst)
    duplicate = User.new(name: "Otro Juan", email: "JUAN@example.com", password: "password123", role: :analyst)

    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end
end
