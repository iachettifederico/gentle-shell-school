require "rails_helper"
require_relative "../support/lesson_fixtures"

RSpec.describe "Lesson pages", type: :request do
  include LessonFixtures

  let(:lessons) {
    {
      "02-odd.md"     => lesson_markdown(slug: "odd", order: 2, title: "Organic driven development",
                                         body: "## Steps\n\nExplore first."),
      "01-welcome.md" => lesson_markdown(slug: "welcome", order: 1, title: "Welcome", body: "Read {origin}/llms.txt"),
      "03-unsafe.md"  => lesson_markdown(slug: "unsafe", order: 3, title: "Unsafe", body: "<script>alert(1)</script>"),
    }
  }

  describe "GET /" do
    it "lists lessons in order, linking to each lesson page" do
      with_lessons(lessons) do
        get "/"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      links = page.css("a[data-lesson]").map { |link| [ link.text.strip, link["href"] ] }
      expect(links).to eq([
                            [ "Welcome", "/lessons/welcome" ],
                            [ "Organic driven development", "/lessons/odd" ],
                            [ "Unsafe", "/lessons/unsafe" ]
                          ])
      expect(response.body).to include("About organic driven development.")
    end
  end

  describe "GET /lessons/:slug" do
    it "renders the lesson title and its Markdown body as HTML" do
      with_lessons(lessons) do
        get "/lessons/odd"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      expect(page.at_css("h1").text).to eq("Organic driven development")
      expect(page.at_css("article h2").text).to eq("Steps")
      expect(page.at_css("article p").text).to eq("Explore first.")
      expect(page.at_css("title").text).to eq("Organic driven development · Gentle Shell School")
    end

    it "resolves {origin} in the body to the request origin" do
      with_lessons(lessons) do
        get "/lessons/welcome"
      end

      expect(response.parsed_body.at_css("article").text).to include("Read http://www.example.com/llms.txt")
    end

    it "escapes raw HTML in lesson Markdown" do
      with_lessons(lessons) do
        get "/lessons/unsafe"
      end

      expect(response.body).not_to include("<script>alert(1)</script>")
    end

    it "returns 404 for an unknown lesson" do
      with_lessons(lessons) do
        get "/lessons/missing"
      end

      expect(response).to have_http_status(:not_found)
    end
  end
end
