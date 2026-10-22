require "rails_helper"

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
    student_id = PendingEnrollment.find_by!(code: code).student.public_id
    get "/api/enrollments/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("status")).to eq("enrolled")
    expect(response.parsed_body.fetch("studentId")).to eq(student_id)
    expect(response.parsed_body).to have_key("progress")

    get "/api/enrollments/missing"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq("error" => "Enrollment not found")

    expired = PendingEnrollment.create!(code: "expired", status: "pending", expires_at: 1.minute.ago)
    get "/api/enrollments/#{expired.code}"
    expect(response).to have_http_status(:gone)
    expect(response.parsed_body).to eq("error" => "Enrollment link expired")
  end

  it "renders pending, missing, expired, and already-used web states without exposing an ID" do
    code = prepare
    get "/enroll/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Enroll", "Not now", "anonymous student ID")

    get "/enroll/missing"
    expect(response).to have_http_status(:not_found)

    PendingEnrollment.create!(code: "expired", status: "pending", expires_at: 1.minute.ago)
    get "/enroll/expired"
    expect(response).to have_http_status(:gone)
    expect(response.body).to include("Ask your agent for a new enrollment link")

    post "/enroll/#{code}"
    get "/enroll/#{code}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("already used")
    expect(response.body).not_to include(PendingEnrollment.find_by!(code: code).student.public_id)
  end

  it "claims once and returns a confirmation that stores the student ID" do
    code = prepare
    expect { post "/enroll/#{code}" }.to change(Student, :count).by(1)
    student_id = PendingEnrollment.find_by!(code: code).student.public_id
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-enrollment-student-id-value=\"#{student_id}\"", "Return to your agent")

    expect { post "/enroll/#{code}" }.not_to change(Student, :count)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("already used")
  end

  it "does not create students for expired claims" do
    PendingEnrollment.create!(code: "expired", status: "pending", expires_at: 1.minute.ago)
    expect { post "/enroll/expired" }.not_to change(Student, :count)
    expect(response).to have_http_status(:gone)
  end

  context "with forgery protection enabled" do
    around do |example|
      previous = ApplicationController.allow_forgery_protection
      ApplicationController.allow_forgery_protection = true
      example.run
    ensure
      ApplicationController.allow_forgery_protection = previous
    end

    it "rejects a cross-site POST without changing enrollment state" do
      code = prepare
      enrollment = PendingEnrollment.find_by!(code: code)

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
  end
end
