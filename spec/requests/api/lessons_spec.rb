require "rails_helper"
require_relative "../../support/lesson_fixtures"

RSpec.describe "Lessons API", type: :request do
  include LessonFixtures

  let(:lessons) {
    {
      "02-odd.md"     => lesson_markdown(slug: "odd", order: 2, title: "Odd", body: "Explore first.", quiz: true),
      "01-welcome.md" => lesson_markdown(
        slug: "welcome", order: 1, title: "Welcome", body: "Read {origin}/llms.txt", module_name: "Getting started"
      ),
    }
  }

  def expect_cors_headers
    expect(response.headers.to_h).to include(
      "access-control-allow-origin"  => "*",
      "access-control-allow-methods" => "GET, OPTIONS",
      "access-control-allow-headers" => "Content-Type"
    )
  end

  describe "GET /api/lessons" do
    let(:welcome_json) {
      {
        "order"             => 1,
        "slug"              => "welcome",
        "title"             => "Welcome",
        "description"       => "About welcome.",
        "module"            => "Getting started",
        "lab"               => nil,
        "locale"            => "en",
        "agentInstructions" => "Verify welcome at http://www.example.com/lessons/welcome.",
        "content"           => "Read http://www.example.com/llms.txt\n",
        "url"               => "http://www.example.com/lessons/welcome",
        "next"              => {
          "slug"   => "odd",
          "title"  => "Odd",
          "url"    => "http://www.example.com/lessons/odd",
          "prompt" => "I'm enrolled in Gentle Shell School as {studentId}. Let's do the \"Odd\" lesson (odd). " \
                      "Fetch http://www.example.com/llms.txt for instructions.",
        },
      }
    }
    let(:odd_json) {
      {
        "order"             => 2,
        "slug"              => "odd",
        "title"             => "Odd",
        "description"       => "About odd.",
        "module"            => nil,
        "lab"               => nil,
        "locale"            => "en",
        "agentInstructions" => "Verify odd at http://www.example.com/lessons/odd.\n\n#{Course::QuizInstructions::TEXT}",
        "content"           => "Explore first.\n",
        "url"               => "http://www.example.com/lessons/odd",
        "next"              => nil,
      }
    }

    it "returns every lesson in order with resolved instructions and content" do
      with_lessons(lessons) do
        get "/api/lessons"
      end

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      expect_cors_headers
      expect(response.parsed_body).to eq([ welcome_json, odd_json ])
    end
  end

  describe "GET /api/lessons/:slug" do
    it "returns one lesson" do
      with_lessons(lessons) do
        get "/api/lessons/welcome"
      end

      expect(response).to have_http_status(:ok)
      expect_cors_headers
      expect(response.parsed_body).to eq(
        "order"             => 1,
        "slug"              => "welcome",
        "title"             => "Welcome",
        "description"       => "About welcome.",
        "module"            => "Getting started",
        "lab"               => nil,
        "locale"            => "en",
        "agentInstructions" => "Verify welcome at http://www.example.com/lessons/welcome.",
        "content"           => "Read http://www.example.com/llms.txt\n",
        "url"               => "http://www.example.com/lessons/welcome",
        "next"              => {
          "slug"   => "odd",
          "title"  => "Odd",
          "url"    => "http://www.example.com/lessons/odd",
          "prompt" => "I'm enrolled in Gentle Shell School as {studentId}. Let's do the \"Odd\" lesson (odd). " \
                      "Fetch http://www.example.com/llms.txt for instructions.",
        }
      )
    end

    it "points the next lesson at the requested language's page and llms.txt" do
      with_lessons(lessons) do
        get "/api/lessons/welcome", params: { locale: "es-AR" }
      end

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["url"]).to eq("http://www.example.com/es-AR/lessons/welcome")
      expect(response.parsed_body["next"]).to eq(
        "slug"   => "odd",
        "title"  => "Odd",
        "url"    => "http://www.example.com/es-AR/lessons/odd",
        "prompt" => "Estoy inscripto en Gentle Shell School como {studentId}. Hagamos la lección \"Odd\" (odd). " \
                    "Leé http://www.example.com/es-AR/llms.txt para ver las instrucciones."
      )
    end

    it "includes the linked lab slug" do
      lab = {
        "feature-document" => {
          metadata: <<~YAML,
            slug: feature-document
            lesson: welcome
            title: Feature document
            brief: Write it.
            check: node --test
            rubric:
              - Complete it.
          YAML
          files:    { "index.js" => "" },
        },
      }

      with_lessons(lessons) do
        with_labs(lab) { get "/api/lessons/welcome" }
      end

      expect(response.parsed_body["lab"]).to eq("feature-document")
    end

    it "returns 404 with an error for an unknown lesson" do
      with_lessons(lessons) do
        get "/api/lessons/missing"
      end

      expect(response).to have_http_status(:not_found)
      expect_cors_headers
      expect(response.parsed_body).to eq("error" => "Lesson not found")
    end
  end

  describe "OPTIONS preflight" do
    it "answers 204 with CORS headers for the collection and a member" do
      %w[/api/lessons /api/lessons/welcome].each do |path|
        process :options, path

        expect(response).to have_http_status(:no_content)
        expect_cors_headers
      end
    end
  end
end
