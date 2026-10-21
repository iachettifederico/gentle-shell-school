require "rails_helper"
require_relative "../../support/lesson_fixtures"

RSpec.describe "Progress API", type: :request do
  include LessonFixtures

  let(:lessons) {
    {
      "01-welcome.md" => lesson_markdown(slug: "welcome", order: 1, title: "Welcome", body: "Start here."),
      "02-next.md"    => lesson_markdown(slug: "next", order: 2, title: "Next", body: "Continue."),
    }
  }

  def enroll
    post "/api/enroll", as: :json
    response.parsed_body.fetch("studentId")
  end

  def progress_json(student_id)
    get "/api/progress/#{student_id}"
    response.parsed_body
  end

  def expect_cors(methods)
    headers = response.headers.to_h
    expect(headers.fetch("access-control-allow-origin")).to eq("*")
    expect(headers.fetch("access-control-allow-methods")).to eq(methods)
    expect(headers.fetch("access-control-allow-headers")).to eq("Content-Type")
  end

  def expect_progress_shape(progress)
    expect(progress.keys).to contain_exactly("completedLessons", "createdAt", "updatedAt")
    expect(progress.fetch("createdAt")).to match(/\A\d{4}-\d{2}-\d{2}T.*Z\z/)
    expect(progress.fetch("updatedAt")).to match(/\A\d{4}-\d{2}-\d{2}T.*Z\z/)
  end

  it "enrolls a student with empty progress" do
    student_id = enroll

    expect(response).to have_http_status(:created)
    expect_cors("POST, OPTIONS")
    expect(student_id).to match(/\A[a-z]+-[a-z]+-\d{4}\z/)
    expect(response.parsed_body).to include("studentId" => student_id)
    expect_progress_shape(response.parsed_body.fetch("progress"))
    expect(response.parsed_body.dig("progress", "completedLessons")).to eq([])
  end

  it "gets progress and reports invalid and unknown student IDs" do
    student_id = enroll
    expected = progress_json(student_id)

    expect(response).to have_http_status(:ok)
    expect_cors("GET, PUT, DELETE, OPTIONS")
    expect_progress_shape(expected)

    get "/api/progress/invalid"
    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body).to eq("error" => "Invalid student ID format")

    get "/api/progress/curious-hacker-2019"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq("error" => "Student not found")
  end

  it "completes a lesson with defaulted source and trimmed model idempotently" do
    with_lessons(lessons) do
      student_id = enroll
      put "/api/progress/#{student_id}", params: { lessonSlug: "welcome", model: "  gpt-5  " }, as: :json
      first = response.parsed_body

      expect(response).to have_http_status(:ok)
      expect_cors("GET, PUT, DELETE, OPTIONS")
      completion = first.fetch("completedLessons").fetch(0)
      expect(completion.keys).to contain_exactly("slug", "completedAt", "source", "model")
      expect(completion.fetch("slug")).to eq("welcome")
      expect(completion.fetch("completedAt")).to match(/\A\d{4}-\d{2}-\d{2}T.*Z\z/)
      expect(completion.fetch("source")).to eq("browser")
      expect(completion.fetch("model")).to eq("gpt-5")

      put "/api/progress/#{student_id}", params: { lessonSlug: "welcome", source: "agent", model: "new" }, as: :json
      second = response.parsed_body
      expect(second.dig("completedLessons", 0, "completedAt")).to eq(first.dig("completedLessons", 0, "completedAt"))
      expect(second.dig("completedLessons", 0, "source")).to eq("browser")
      expect(second.dig("completedLessons", 0, "model")).to eq("gpt-5")

      put "/api/progress/#{student_id}", params: { lessonSlug: "next", source: "agent", model: " " }, as: :json
      agent_completion = response.parsed_body.fetch("completedLessons").find { |item| item.fetch("slug") == "next" }
      expect(agent_completion.keys).to contain_exactly("slug", "completedAt", "source")
      expect(agent_completion.fetch("slug")).to eq("next")
      expect(agent_completion.fetch("completedAt")).to match(/\A\d{4}-\d{2}-\d{2}T.*Z\z/)
      expect(agent_completion.fetch("source")).to eq("agent")
    end
  end

  it "rejects invalid PUT input without changing stored progress" do
    with_lessons(lessons) do
      student_id = enroll
      before = progress_json(student_id)
      initial_students = Student.count
      initial_completions = LessonCompletion.count

      [
        [ { lessonSlug: "" }, "Missing or invalid \"lessonSlug\" field" ],
        [ { lessonSlug: "missing" }, "Unknown lesson slug: \"missing\"" ],
      ].each do |payload, error|
        put "/api/progress/#{student_id}", params: payload, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => error)
        expect(progress_json(student_id)).to eq(before)
        expect([ Student.count, LessonCompletion.count ]).to eq([ initial_students, initial_completions ])
      end

      put "/api/progress/invalid", params: { lessonSlug: "welcome" }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Invalid student ID format")
      expect(progress_json(student_id)).to eq(before)

      put "/api/progress/curious-hacker-2019", params: { lessonSlug: "welcome" }, as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Student not found")
      expect(progress_json(student_id)).to eq(before)
    end
  end

  it "rejects invalid JSON without changing stored progress" do
    student_id = enroll
    before = progress_json(student_id)

    put "/api/progress/#{student_id}", params: "{", headers: { "CONTENT_TYPE" => "application/json" }

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body).to eq("error" => "Invalid JSON body")
    expect(progress_json(student_id)).to eq(before)
  end

  it "uncompletes a lesson or resets a student while retaining the student" do
    with_lessons(lessons) do
      student_id = enroll
      %w[welcome next].each do |slug|
        put "/api/progress/#{student_id}", params: { lessonSlug: slug }, as: :json
      end

      delete "/api/progress/#{student_id}", params: { lessonSlug: "welcome" }, as: :json
      expect(response).to have_http_status(:ok)
      slugs = response.parsed_body.fetch("completedLessons").map { |completion| completion.fetch("slug") }
      expect(slugs).to eq([ "next" ])

      delete "/api/progress/#{student_id}", params: { reset: true }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch("completedLessons")).to eq([])
      expect(Student.find_by(public_id: student_id)).to be_present
    end
  end

  it "rejects invalid DELETE input without changing stored progress" do
    with_lessons(lessons) do
      student_id = enroll
      put "/api/progress/#{student_id}", params: { lessonSlug: "welcome" }, as: :json
      before = progress_json(student_id)
      initial_counts = [ Student.count, LessonCompletion.count ]

      [
        [ {}, "Provide \"lessonSlug\" or \"reset\": true" ],
        [ { lessonSlug: "" }, "Missing or invalid \"lessonSlug\" field" ],
        [ { lessonSlug: "missing" }, "Unknown lesson slug: \"missing\"" ],
      ].each do |payload, error|
        delete "/api/progress/#{student_id}", params: payload, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => error)
        expect(progress_json(student_id)).to eq(before)
        expect([ Student.count, LessonCompletion.count ]).to eq(initial_counts)
      end

      delete "/api/progress/invalid", params: { reset: true }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(progress_json(student_id)).to eq(before)

      delete "/api/progress/curious-hacker-2019", params: { reset: true }, as: :json
      expect(response).to have_http_status(:not_found)
      expect(progress_json(student_id)).to eq(before)
    end
  end

  it "serves instructions as plain text and errors as JSON" do
    student_id = enroll
    get "/api/instructions/#{student_id}"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/plain")
    expect_cors("GET, OPTIONS")
    expect(response.body).to include("My Gentle Shell School student ID is #{student_id}")
    expect(response.body).to include("http://www.example.com/llms.txt")

    get "/api/instructions/invalid"
    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body).to eq("error" => "Invalid student ID format")
  end

  it "answers endpoint-specific preflights" do
    preflights = [
      [ "/api/enroll", "POST, OPTIONS" ],
      [ "/api/progress/curious-hacker-2019", "GET, PUT, DELETE, OPTIONS" ],
      [ "/api/instructions/curious-hacker-2019", "GET, OPTIONS" ],
      [ "/api/lessons", "GET, OPTIONS" ],
    ]
    preflights.each do |path, methods|
      process :options, path
      expect(response).to have_http_status(:no_content)
      expect_cors(methods)
    end
  end
end
