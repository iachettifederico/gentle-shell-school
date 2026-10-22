require "rails_helper"
require_relative "../support/lesson_fixtures"

RSpec.describe "Lesson pages", type: :request do
  include LessonFixtures

  let(:lessons) {
    {
      "02-odd.md"     => lesson_markdown(
        slug: "odd", order: 2, title: "Organic driven development",
        body: "## Steps\n\nExplore first.", module_name: "Foundations"
      ),
      "01-welcome.md" => lesson_markdown(
        slug: "welcome", order: 1, title: "Welcome", body: "Read {origin}/llms.txt", module_name: "Getting started"
      ),
      "03-unsafe.md"  => lesson_markdown(
        slug: "unsafe", order: 3, title: "Unsafe", body: "<script>alert(1)</script>", module_name: "Foundations"
      ),
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
      expect(page.at_css('meta[name="description"]')["content"])
        .to include("coding agent")
      expect(page.at_css('meta[property="og:title"]')["content"])
        .to eq("Gentle Shell School")
      expect(page.css("h3[data-module-name]").pluck("data-module-name"))
        .to eq([ "Getting started", "Foundations" ])
      expect(page.css("[data-module-total]").map { |count| [ count["data-module-total"], count.text.strip ] })
        .to eq([[ "1", "0/1 done" ], [ "2", "0/2 done" ]])
      expect(page.at_css('a[href="https://github.com/iachettifederico/gentle-shell-school/issues/new?template=course-feedback.yml&lesson=site"]')&.text&.strip)
        .to eq("Report a problem")
    end

    it "offers an any-agent start prompt and gentle-shell links" do
      with_lessons(lessons) do
        get "/"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      expect(page.at_css("h2", text: "Start with any coding agent")).to be_present
      expect(response.body).to include("Read http://www.example.com/llms.txt and start the course.")
      copy_button = page.at_css(
        'button[data-prompt="Read http://www.example.com/llms.txt and start the course."]'
      )
      expect(copy_button&.text&.strip).to eq("Copy")
      expect(page.at_css('a[href="/lessons/welcome"]')&.text&.strip)
        .to eq("Already using gentle-shell? Start here")
      expect(page.at_css('a[href="https://github.com/Gentleman-Programming/gentle-shell#readme"]')&.text&.strip)
        .to eq("Install gentle-shell yourself")
    end

    it "renders the enrollment controls and progress hooks" do
      with_lessons(lessons) do
        get "/"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      expect(page.at_css('[data-controller="progress"]')).to be_present
      enroll_button = page.at_css('[data-progress-target="enrollButton"]')
      expect(enroll_button.text.strip).to eq("Enroll")
      expect(enroll_button["data-action"]).to eq("progress#enroll")
      expect(page.at_css('[data-progress-target="student"]')).to be_present
      expect(page.at_css('[data-progress-target="studentId"]')).to be_present
      expect(page.at_css('[data-progress-target="instructionsUrl"]')).to be_present
      expect(page.at_css('[data-progress-target="forgetButton"]').text.strip).to eq("Forget this ID")
      lesson_slugs = page.css('[data-progress-target="lesson"]').pluck("data-lesson-slug")
      expect(lesson_slugs).to eq(%w[welcome odd unsafe])
      expect(page.css('[data-progress-target="completion"]').count).to eq(3)
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
      expect(page.at_css('meta[name="description"]')["content"])
        .to eq("About organic driven development.")
      expect(page.at_css('meta[property="og:title"]')["content"])
        .to eq("Organic driven development · Gentle Shell School")
      expect(page.at_css('meta[property="og:description"]')["content"])
        .to eq("About organic driven development.")
      expect(page.at_css('a[href="https://github.com/iachettifederico/gentle-shell-school/issues/new?template=course-feedback.yml&lesson=odd&title=%5BCourse+feedback%5D+odd%3A+"]')&.text&.strip)
        .to eq("Report a problem with this lesson")
    end

    it "renders navigation, module, and teach-me prompt for the lesson" do
      with_lessons(lessons) do
        get "/lessons/odd"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      expect(page.at_css("[data-lesson-module]").text.strip).to eq("Foundations")
      navigation = page.css("[data-lesson-navigation] a")
      expect(navigation.pluck("href")).to eq([ "/lessons/welcome", "/lessons/unsafe" ])
      expect(navigation.map(&:text).map(&:squish))
        .to eq([ "Previous lesson Welcome", "Next lesson Unsafe" ])
      expect(page.at_css("[data-teach-me-prompt]").text.strip)
        .to eq('Read http://www.example.com/llms.txt and teach me the "Organic driven development" lesson (odd).')
    end

    it "omits unavailable previous or next navigation links" do
      with_lessons(lessons) do
        get "/lessons/welcome"
      end

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      navigation = page.css("[data-lesson-navigation] a").map(&:text).map(&:squish)
      expect(navigation).to eq([ "Next lesson Organic driven development" ])
      expect(page.at_css('a[href="https://github.com/iachettifederico/gentle-shell-school/issues/new?template=course-feedback.yml&lesson=welcome&title=%5BCourse+feedback%5D+welcome%3A+"]')&.text&.strip)
        .to eq("Report a problem with this lesson")
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
      expect(response.parsed_body.css('a[href="/"]').map(&:text).map(&:strip)).to include("Back to the course")
    end
  end
end
