require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Token Tester",
      email: "token-tester@example.com",
      password: "password123",
      role: :admin
    )
  end

  test "issue returns a raw token but stores only a digest" do
    raw = ApiToken.issue!(user: @user)
    stored = ApiToken.order(:id).last

    assert_match(/\A[a-f0-9]{64}\z/, raw)
    assert_equal Digest::SHA256.hexdigest(raw), stored.token_digest
    assert_not_equal raw, stored.token_digest
    assert stored.expires_at.future?
  end

  test "expired tokens are not valid" do
    raw = ApiToken.issue!(user: @user)
    token = ApiToken.find_by!(token_digest: Digest::SHA256.hexdigest(raw))
    token.update!(expires_at: 1.minute.ago)

    assert_not_includes ApiToken.valid_now, token
  end
end
