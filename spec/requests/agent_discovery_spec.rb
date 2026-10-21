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
      expect(response.body).to include("POST http://www.example.com/api/enroll")
      expect(response.body).to include("source: \"agent\"")
      expect(response.body).to include("DELETE http://www.example.com/api/progress/{studentId}")
      expect(response.body).to include("http://www.example.com/api/instructions/{studentId}")
      expect(response.body).not_to include("Progress tracking is not available yet")
      expect(response.body).not_to include("{origin}")
    end
  end

  describe "GET /api/openapi.json" do
    it "describes the lessons endpoints for the serving origin" do
      get "/api/openapi.json"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      document = response.parsed_body
      expect(document["openapi"]).to eq("3.1.0")
      expect(document["servers"]).to eq([ { "url" => "http://www.example.com" } ])
      expect(document["paths"].keys).to contain_exactly(
        "/api/enroll", "/api/progress/{student_id}", "/api/instructions/{student_id}",
        "/api/lessons", "/api/lessons/{slug}"
      )
      expect(document.dig("components", "schemas", "Lesson", "required"))
        .to eq(%w[order slug title description agentInstructions content])
      expect(document.dig("components", "schemas", "Enrollment", "required")).to eq(%w[studentId progress])
      expect(document.dig("components", "schemas", "Progress", "required"))
        .to eq(%w[completedLessons createdAt updatedAt])
      expect(document.dig("paths", "/api/progress/{student_id}", "put", "responses").keys)
        .to contain_exactly("200", "400", "404")
    end
  end
end
