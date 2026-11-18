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
  test "admin creates a case through JSON API and can read it back" do
    token = ApiToken.issue!(user: @admin)
    headers = { "Authorization" => "Bearer #{token}" }

    post "/api/v1/cases",
         params: { case: { code: "TP2-CASE-001", title: "Investigación integrada", opened_at: "2026-11-18", status: "open" } },
         headers: headers, as: :json
    assert_response :created
    id = response.parsed_body.fetch("id")
    assert_equal "TP2-CASE-001", Case.find(id).code

    get "/api/v1/cases", headers: headers
    assert_response :success
    assert(response.parsed_body.any? { |record| record["id"] == id })
  end

  test "duplicate case code returns validation errors" do
    Case.create!(code: "TP2-DUPLICATE", title: "Existente", opened_at: Time.current)
    token = ApiToken.issue!(user: @admin)

    post "/api/v1/cases",
         params: { case: { code: "TP2-DUPLICATE", title: "Duplicado", opened_at: "2026-11-18" } },
         headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").any?
  end

end
