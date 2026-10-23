require "rails_helper"

# The course has one entry path: the lesson page's prompt. The agent enrollment
# handshake and its pages are gone; the website's Enroll button remains.
RSpec.describe "Single course path", type: :request do
  it "no longer serves the agent enrollment handshake or its pages" do
    post "/api/enrollments", as: :json
    expect(response).to have_http_status(:not_found)

    get "/api/enrollments/some-code"
    expect(response).to have_http_status(:not_found)

    get "/enroll/some-code"
    expect(response).to have_http_status(:not_found)

    get "/es-AR/enroll/some-code"
    expect(response).to have_http_status(:not_found)
  end

  it "keeps the website's Enroll button endpoint" do
    post "/api/enroll", as: :json

    expect(response).to have_http_status(:created).or have_http_status(:ok)
    expect(response.parsed_body["studentId"]).to match(/\A[a-z]+-[a-z]+-\d{4}\z/)
  end

  it "ships no Pi package or /school tutor" do
    expect(Rails.root.join("agent")).not_to exist
    expect(JSON.parse(Rails.root.join("package.json").read)).not_to have_key("pi")
  end

  it "keeps the student ID out of logged parameters and query strings" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    expect(filter.filter("sid" => "clever-maker-1234", "student_id" => "clever-maker-1234", "slug" => "welcome"))
      .to eq("sid" => "[FILTERED]", "student_id" => "[FILTERED]", "slug" => "welcome")

    env = Rails.application.env_config.merge(Rack::MockRequest.env_for("/es-AR/lessons/welcome?sid=clever-maker-1234"))
    request = ActionDispatch::Request.new(env)
    expect(request.filtered_path).to eq("/es-AR/lessons/welcome?sid=[FILTERED]")
  end

  it "links llms.txt in the language being read" do
    get "/es-AR"

    page = response.parsed_body
    expect(page.css('a[href$="llms.txt"]').pluck("href").uniq).to eq([ "/es-AR/llms.txt" ])

    get "/"

    expect(response.parsed_body.css('a[href$="llms.txt"]').pluck("href").uniq).to eq([ "/llms.txt" ])
  end
end
