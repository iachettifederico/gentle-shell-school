require "rails_helper"

RSpec.describe "Agent discovery", type: :request do
  describe "GET /llms.txt" do
    it "teaches one lesson at a time in English and hands back the next prompt" do
      get "/llms.txt"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      body = response.body
      expect(body).to start_with("# Gentle Shell School\n")
      expect(body).to include("Language: English (`en`).")
      expect(body).to include("Never ask the student to choose a language")
      expect(body).to include("GET http://www.example.com/api/lessons/{slug}?locale=en")
      expect(body).to include("I'm enrolled in Gentle Shell School as <id>")
      expect(body).to include("`next.prompt`")
      expect(body).to include(
        "When `agentInstructions` include quiz questions, ask exactly those with the ask_user_question tool; " \
        "never invent quiz questions. Write the answer choices yourself, including the correct answer"
      )
      expect(body).to include(
        "keep the wrong choices on the lesson's topic and never misdescribe how this course works"
      )
      expect(body).not_to include("Never invent quiz questions or answer choices")
      expect(body).to include(
        "If the ask_user_question tool is unavailable, ask the same questions and offer the same choices " \
        "in plain text, then wait for the answer."
      )
      expect(body).not_to include("Ask quiz questions with the ask_user_question tool")
      expect(body).to include("`next.url`?sid=<id>")
      expect(body).to include("PUT http://www.example.com/api/progress/{studentId}")
      expect(body).to include("DELETE http://www.example.com/api/progress/{studentId}")
      expect(body).to include("http://www.example.com/api/openapi.json")
      expect(body).to include("GET http://www.example.com/api/labs/{slug}?locale=en")
      expect(body).to include("Coach with `monitor` while the check runs")
      expect(body).to include(
        "The check covers only what a script can observe: passing it alone does not complete the lab."
      )
      expect(body).to include(
        "The fresh-context rubric grade is the evidence for the lab's actual outcome; " \
        "record both it and the check result."
      )
      expect(body).to include('"Report it and continue", "Continue without reporting", "Stop here"')
      expect(body).to include("[Course feedback] <lesson-slug>: <short summary>")
      expect(body).to include("gh issue create --repo iachettifederico/gentle-shell-school")
      expect(body).to include("issues/new?template=course-feedback.yml")
      expect(body).to include('"Log in with gh now", "Open a prefilled link in my browser", "Skip reporting"')
      expect(body).not_to include("/school")
      expect(body).not_to include("/api/enrollments")
      expect(body).not_to include("Any coding agent")
      expect(body).not_to include("which language")
      expect(body).not_to include("{origin}")
    end

    it "fixes the language from the localized llms.txt URL" do
      get "/es-AR/llms.txt"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to include("Language: Spanish (Argentina) (`es-AR`).")
      expect(response.body).to include("Rioplatense Spanish with voseo")
      expect(response.body).to include("GET http://www.example.com/api/lessons/{slug}?locale=es-AR")
      expect(response.body).to include("Never ask the student to choose a language")

      get "/es/llms.txt"

      expect(response.body).to include("Language: Spanish (`es`).")
      expect(response.body).to include("GET http://www.example.com/api/lessons/{slug}?locale=es")
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
        "/api/enroll",
        "/api/progress/{student_id}", "/api/instructions/{student_id}",
        "/api/labs", "/api/labs/{slug}", "/api/lessons", "/api/lessons/{slug}"
      )
      expect(document.dig("components", "schemas", "Lesson", "required"))
        .to eq(%w[order slug title description agentInstructions content lab locale url next])
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
