require "rails_helper"
require "digest"

RSpec.describe "Enrollment handshake", type: :request do
  def prepare
    post "/api/enrollments", as: :json
    response.parsed_body.fetch("code")
  end

  it "creates a pending enrollment without creating a student" do
    expect { prepare }.not_to change(Student, :count)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("status" => "pending")
    expect(response.parsed_body.fetch("enrollUrl")).to eq("http://www.example.com/enroll/#{response.parsed_body.fetch('code')}")
    expect(response.parsed_body.fetch("expiresAt")).to match(/Z\z/)
  end

  it "reports pending, enrolled, missing, and expired API enrollments" do
    code = prepare
    get "/api/enrollments/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.keys).to contain_exactly("status", "expiresAt")
    expect(response.parsed_body.fetch("status")).to eq("pending")

    post "/enroll/#{code}"
    student_id = pending_enrollment(code).student.public_id
    get "/api/enrollments/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("status")).to eq("enrolled")
    expect(response.parsed_body.fetch("studentId")).to eq(student_id)
    expect(response.parsed_body).to have_key("progress")

    get "/api/enrollments/missing"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq("error" => "Enrollment not found")

    create_expired_enrollment("expired")
    get "/api/enrollments/expired"
    expect(response).to have_http_status(:gone)
    expect(response.parsed_body).to eq("error" => "Enrollment link expired")
  end

  it "renders a native Enroll form so confirmation can store the student ID" do
    code = prepare

    get "/enroll/#{code}"

    expect(response.body).to include('data-turbo="false"')
  end

  it "renders pending, missing, expired, and already-used web states without exposing an ID" do
    code = prepare
    get "/enroll/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Enroll", "Not now", "anonymous student ID")

    get "/enroll/missing"
    expect(response).to have_http_status(:not_found)

    create_expired_enrollment("expired")
    get "/enroll/expired"
    expect(response).to have_http_status(:gone)
    expect(response.body).to include("Ask your agent for a new enrollment link")

    post "/enroll/#{code}"
    get "/enroll/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("already used")
    expect(response.body).not_to include(pending_enrollment(code).student.public_id)
  end

  it "claims once and returns a confirmation that stores the student ID" do
    code = prepare
    expect { post "/enroll/#{code}" }.to change(Student, :count).by(1)
    student_id = pending_enrollment(code).student.public_id
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-enrollment-student-id-value=\"#{student_id}\"", "Return to your agent")

    expect { post "/enroll/#{code}" }.not_to change(Student, :count)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("already used")
  end

  it "does not create students for expired claims" do
    create_expired_enrollment("expired")
    expect { post "/enroll/expired" }.not_to change(Student, :count)
    expect(response).to have_http_status(:gone)
  end

  def pending_enrollment(code)
    PendingEnrollment.find_by!(code_digest: Digest::SHA256.hexdigest(code))
  end

  def create_expired_enrollment(code)
    PendingEnrollment.create!(code_digest: Digest::SHA256.hexdigest(code), status: "pending", expires_at: 1.minute.ago)
  end

  context "with forgery protection enabled" do
    around do |example|
      previous_config = Rails.application.config.action_controller.allow_forgery_protection
      previous_base = ActionController::Base.allow_forgery_protection
      previous_application = ApplicationController.allow_forgery_protection
      Rails.application.config.action_controller.allow_forgery_protection = true
      ActionController::Base.allow_forgery_protection = true
      ApplicationController.allow_forgery_protection = true
      example.run
    ensure
      Rails.application.config.action_controller.allow_forgery_protection = previous_config
      ActionController::Base.allow_forgery_protection = previous_base
      ApplicationController.allow_forgery_protection = previous_application
    end

    it "rejects a tokenless POST with no Fetch Metadata header" do
      code = prepare
      enrollment = pending_enrollment(code)

      expect { post "/enroll/#{code}" }.not_to change(Student, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(enrollment.reload).to have_attributes(status: "pending", student_id: nil)
    end

    it "rejects a cross-site POST without changing enrollment state" do
      code = prepare
      enrollment = pending_enrollment(code)

      expect { post "/enroll/#{code}", headers: { "Sec-Fetch-Site" => "cross-site" } }
        .not_to change(Student, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(enrollment.reload).to have_attributes(status: "pending", student_id: nil)
    end

    it "accepts a same-origin POST" do
      code = prepare

      expect { post "/enroll/#{code}", headers: { "Sec-Fetch-Site" => "same-origin" } }
        .to change(Student, :count).by(1)
      expect(response).to have_http_status(:ok)
    end

    it "accepts a valid form token when Fetch Metadata is absent" do
      code = prepare
      get "/enroll/#{code}"
      token = response.body[/<input[^>]*name="authenticity_token"[^>]*value="([^"]+)"/, 1]
      token ||= response.body[/<input[^>]*value="([^"]+)"[^>]*name="authenticity_token"/, 1]
      token = CGI.unescapeHTML(token)

      expect { post "/enroll/#{code}", params: { authenticity_token: token } }.to change(Student, :count).by(1)
      expect(response).to have_http_status(:ok)
    end
  end
end
