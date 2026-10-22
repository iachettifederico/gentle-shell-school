require "rails_helper"
require_relative "../support/lesson_fixtures"

RSpec.describe "Localized course delivery", type: :request do
  include LessonFixtures

  let(:lessons) {
    { "01-welcome.md" => lesson_markdown(slug: "welcome", order: 1, title: "Welcome", body: "English body",
                                         module_name: "Start") }
  }

  it "serves Spanish website routes, localized links, language metadata, and remembers only the switcher choice" do
    with_lessons(lessons) do
      get "/es/lessons/welcome"
    end

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("html")["lang"]).to eq("es")
    expect(response.parsed_body.at_css('a[href="/es"]')).to be_present
    expect(response.parsed_body.css('link[rel="alternate"]').pluck("hreflang")).to contain_exactly("en", "es", "es-AR")
    expect(response.cookies["course_locale"]).to eq("es")
  end

  it "keeps English at the root and rejects unknown locale prefixes" do
    with_lessons(lessons) do
      get "/lessons/welcome"
    end
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("html")["lang"]).to eq("en")

    get "/fr/lessons/welcome"
    expect(response).to have_http_status(:not_found)
  end

  it "overlays a translated lesson file and reports the translation actually served by the API" do
    with_lessons(lessons.merge(
                   "es/01-welcome.md" => <<~MD
                     ---
                     title: "Bienvenida"
                     description: "Sobre bienvenida."
                     module: "Inicio"
                     ---

                     Cuerpo en español
                   MD
                 )) do
      get "/api/lessons/welcome?locale=es-AR"
    end

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "title" => "Bienvenida", "module" => "Inicio", "content" => "Cuerpo en español\n", "locale" => "es"
    )
    expect(response.parsed_body.fetch("agentInstructions")).to include("Verify welcome")
  end

  it "rejects unsupported API locales with the exact error" do
    get "/api/lessons?locale=fr"

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body).to eq("error" => "Unsupported locale: \"fr\"")
  end
end
