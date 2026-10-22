require "rails_helper"

RSpec.describe "Agent discovery", type: :request do
  describe "GET /llms.txt" do
    it "explains the school and API using the request origin" do
      get "/llms.txt"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to start_with("# Gentle Shell School\n")
      expect(response.body).to include("http://www.example.com/api/lessons")
      expect(response.body).to include("http://www.example.com/api/openapi.json")
      expect(response.body).to include("agentInstructions")
      expect(response.body).to include("Any coding agent can start this course.")
      expect(response.body).to include(
        "If you are already gentle-shell, verify your own identity and gentle-shell tools, " \
        "then run `gentle-shell --version`."
      )
      expect(response.body).to include(
        "Read http://www.example.com/llms.txt. My Gentle Shell School student ID is <id>. " \
        "Continue the course."
      )
      expect(response.body).to include("POST http://www.example.com/api/enroll")
      expect(response.body).to include("source: \"agent\"")
      expect(response.body).to include("DELETE http://www.example.com/api/progress/{studentId}")
      expect(response.body).to include("http://www.example.com/api/instructions/{studentId}")
      expect(response.body).to include('"Report it and continue", "Continue without reporting", "Stop here"')
      expect(response.body).to include("[Course feedback] <lesson-slug>: <short summary>")
      expect(response.body).to include("gh issue create --repo iachettifederico/gentle-shell-school")
      expect(response.body).to include("issues/new?template=course-feedback.yml")
      expect(response.body).to include('"Log in with gh now", "Open a prefilled link in my browser", "Skip reporting"')
      expect(response.body).to include("pi install git:github.com/iachettifederico/gentle-shell-school")
      expect(response.body).to include("/school")
      expect(response.body).to include("GET http://www.example.com/api/labs/:slug")
      expect(response.body).to include("Coach with `monitor` while the check runs")
      expect(response.body).not_to include("Progress tracking is not available yet")
      expect(response.body).not_to include("{origin}")
    end
  end

  describe "GET /api/openapi.json" do
    it "describes the lessons and labs endpoints for the serving origin" do
      get "/api/openapi.json"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      document = response.parsed_body
      expect(document["openapi"]).to eq("3.1.0")
      expect(document["servers"]).to eq([ { "url" => "http://www.example.com" } ])
      expect(document["paths"].keys).to contain_exactly(
        "/api/enroll", "/api/enrollments", "/api/enrollments/{code}",
        "/api/progress/{student_id}", "/api/instructions/{student_id}",
        "/api/labs", "/api/labs/{slug}", "/api/lessons", "/api/lessons/{slug}"
      )
      expect(document.dig("components", "schemas", "Lesson", "required"))
        .to eq(%w[order slug title description agentInstructions content lab])
      expect(document.dig("components", "schemas", "Lab", "allOf", 1, "required"))
        .to eq(%w[brief check rubric files])
      expect(document.dig("components", "schemas", "Enrollment", "required")).to eq(%w[studentId progress])
      expect(document.dig("components", "schemas", "Progress", "required"))
        .to eq(%w[completedLessons createdAt updatedAt])
      expect(document.dig("paths", "/api/progress/{student_id}", "put", "responses").keys)
        .to contain_exactly("200", "400", "404")
      expect(document.dig("info", "description"))
        .to include("https://github.com/iachettifederico/gentle-shell-school/issues")
    end
  end

  describe "GET /api/instructions/:student_id" do
    it "points agents to the reporting instructions" do
      post "/api/enroll", as: :json
      get "/api/instructions/#{response.parsed_body.fetch('studentId')}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reporting problems")
      expect(response.body).to include("http://www.example.com/llms.txt")
    end
  end
end
