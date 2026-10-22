require "rails_helper"
require_relative "../support/lesson_fixtures"

RSpec.describe "Lesson body accessibility", type: :request do
  include LessonFixtures

  let(:body) { "## Getting started\n\nSee [the steps](#getting-started).\n\n```bash\nls -la\n```\n" }

  it "keeps an accessible name on every heading permalink" do
    with_lessons("01-one.md" => lesson_markdown(slug: "one", order: 1, title: "One", body: body)) do
      get "/lessons/one"

      expect(response).to have_http_status(:ok)
      anchor = response.parsed_body.at_css("article h2#getting-started a.anchor")
      expect(anchor["href"]).to eq("#getting-started")
      expect(anchor["aria-label"]).to eq("Link to heading 'Getting started'")
    end
  end

  it "marks code block languages with a class instead of the lang attribute" do
    with_lessons("01-one.md" => lesson_markdown(slug: "one", order: 1, title: "One", body: body)) do
      get "/lessons/one"

      expect(response).to have_http_status(:ok)
      page = response.parsed_body
      expect(page.css("article pre[lang]")).to be_empty
      expect(page.at_css("article pre code")["class"]).to eq("language-bash")
      expect(page.at_css("article pre code").text).to eq("ls -la\n")
    end
  end

  it "joins soft-wrapped source lines into one flowing paragraph" do
    wrapped = "A commit is a\n**work unit** that\nreviewers understand.\n"
    with_lessons("01-one.md" => lesson_markdown(slug: "one", order: 1, title: "One", body: wrapped)) do
      get "/lessons/one"

      expect(response).to have_http_status(:ok)
      paragraph = response.parsed_body.at_css("article p")
      expect(paragraph.css("br")).to be_empty
      expect(paragraph.text.squish).to eq("A commit is a work unit that reviewers understand.")
    end
  end
end
