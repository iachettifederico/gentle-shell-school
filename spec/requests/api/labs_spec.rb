require "rails_helper"
require_relative "../../support/lesson_fixtures"

RSpec.describe "Labs API", type: :request do
  include LessonFixtures

  let(:labs) { { "red-green" => lab } }

  def lab
    { metadata: lab_metadata, files: { "index.js" => "module.exports = {};\n", "test/index.test.js" => "// test\n" } }
  end

  def lab_metadata
    <<~YAML
      slug: red-green
      lesson: test-first
      title: Red, green
      brief: Make the test pass.
      check: node --test
      rubric:
        - Tests pass.
    YAML
  end

  def expect_cors_headers
    cors_headers.each { |header, value| expect(response.headers[header]).to eq(value) }
  end

  def cors_headers
    {
      "Access-Control-Allow-Origin"  => "*",
      "Access-Control-Allow-Methods" => "GET, OPTIONS",
      "Access-Control-Allow-Headers" => "Content-Type",
    }
  end

  it "lists labs, shows starter files, and reports an unknown lab" do
    with_labs(labs) do
      get "/api/labs"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("labs" => [ lab_summary ])
      expect_cors_headers

      get "/api/labs/red-green"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(lab_detail)

      get "/api/labs/missing"
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Lab not found")
      expect_cors_headers
    end
  end

  it "answers malformed or nested lab paths with the JSON not-found error" do
    [ "/api/labs/..%2F..%2Fconfig", "/api/labs/nested/path", "/api/labs/red-green/lab.yml" ].each do |path|
      get path
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Lab not found")
    end
  end

  it "answers CORS preflight for the collection and member" do
    %w[/api/labs /api/labs/red-green].each do |path|
      process :options, path
      expect(response).to have_http_status(:no_content)
      expect_cors_headers
    end
  end

  def lab_summary
    { "slug" => "red-green", "lesson" => "test-first", "title" => "Red, green" }
  end

  def lab_detail
    lab_summary.merge(
      "brief" => "Make the test pass.", "check" => "node --test", "rubric" => [ "Tests pass." ],
      "files" => [
        { "path" => "index.js", "content" => "module.exports = {};\n" },
        { "path" => "test/index.test.js", "content" => "// test\n" },
      ]
    )
  end
end
