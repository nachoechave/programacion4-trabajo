require "test_helper"

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin API", email: "api-admin@example.com", password: "strongpassword", role: :admin)
    @analyst = User.create!(name: "Analista API", email: "api-analyst@example.com", password: "strongpassword", role: :analyst)
  end

  test "API rejects anonymous requests" do
    get "/api/v1/cases"
    assert_response :unauthorized
  end

  test "valid credentials create a token usable for the API" do
    post "/api/v1/login", params: { email: @admin.email, password: "strongpassword" }, as: :json
    assert_response :created
    token = response.parsed_body.fetch("token")
    get "/api/v1/cases", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
  end

  test "incorrect password is rejected" do
    post "/api/v1/login", params: { email: @admin.email, password: "incorrect" }, as: :json
    assert_response :unauthorized
  end

  test "inactive user token is rejected" do
    token = ApiToken.issue!(user: @admin)
    @admin.update!(active: false)
    get "/api/v1/cases", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end

  test "expired token is rejected" do
    token = ApiToken.issue!(user: @admin)
    ApiToken.last.update!(expires_at: 1.minute.ago)
    get "/api/v1/cases", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end

  test "analyst cannot create cases" do
    token = ApiToken.issue!(user: @analyst)
    post "/api/v1/cases", params: { case: { code: "API-NEW", title: "Case", opened_at: Time.current } },
         headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :forbidden
  end

  test "logout revokes the token" do
    token = ApiToken.issue!(user: @admin)
    delete "/api/v1/logout", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :no_content
    get "/api/v1/cases", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end
end
