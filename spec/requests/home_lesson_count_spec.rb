require "rails_helper"
require_relative "../support/lesson_fixtures"

RSpec.describe "Home page lesson count", type: :request do
  include LessonFixtures

  it "counts the lessons of the course being served" do
    lessons = {
      "01-one.md" => lesson_markdown(slug: "one", order: 1, title: "One", body: "First."),
      "02-two.md" => lesson_markdown(slug: "two", order: 2, title: "Two", body: "Second."),
    }

    with_lessons(lessons) do
      get "/"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css("[data-lesson-count]").text.strip).to eq("2 lessons")
    end
  end
end
