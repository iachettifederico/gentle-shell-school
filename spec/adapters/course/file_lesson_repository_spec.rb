require "spec_helper"
require "tmpdir"
require_relative "../../support/course_lessons"
require_relative "../../../app/adapters/course/file_lesson_repository"

RSpec.describe Course::FileLessonRepository do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def write_lesson(name, content)
    File.write(File.join(@dir, name), content)
  end

  def lesson_file(slug:, order:, quiz: false, extra: "")
    <<~MD
      ---
      title: "#{slug.capitalize}"
      slug: #{slug}
      description: "About #{slug}."
      order: #{order}
      quiz: #{quiz}
      #{extra}agent_instructions: |
        Confirm {origin} works.
        Then mark it complete.
      ---

      # #{slug.capitalize}

      Lesson body.
    MD
  end

  let(:repository) { described_class.new(directory: @dir) }

  it "loads every Markdown lesson into an ordered catalog" do
    write_lesson("02-odd.md", lesson_file(slug: "odd", order: 2, quiz: true))
    write_lesson("01-welcome.md", lesson_file(slug: "welcome", order: 1))
    write_lesson("notes.txt", "ignored")

    catalog = repository.catalog

    expect(catalog.lessons.map(&:slug)).to eq(%w[welcome odd])
    odd = catalog.find("odd")
    expect(odd).to have_attributes(title: "Odd", description: "About odd.", order: 2)
    expect(odd.quiz?).to be(true)
    expect(odd.body_for(origin: "http://x.test")).to eq("# Odd\n\nLesson body.\n")
    expect(odd.agent_instructions_for(origin: "http://x.test"))
      .to start_with("Confirm http://x.test works.\nThen mark it complete.")
  end

  it "returns an empty catalog for an empty directory" do
    expect(repository.catalog.lessons).to eq([])
  end

  it "names the file when frontmatter is missing" do
    write_lesson("01-broken.md", "# No frontmatter\n")

    expect { repository.catalog }
      .to raise_error(Course::InvalidLesson, /01-broken\.md: missing YAML frontmatter/)
  end

  it "names the file when the YAML is malformed" do
    write_lesson("01-broken.md", "---\ntitle: [unclosed\n---\nBody\n")

    expect { repository.catalog }
      .to raise_error(Course::InvalidLesson, /01-broken\.md: invalid YAML frontmatter/)
  end

  it "names the file when a lesson breaks an invariant" do
    write_lesson("01-broken.md", lesson_file(slug: "broken", order: 1).sub(/^title: .*\n/, ""))

    expect { repository.catalog }
      .to raise_error(Course::InvalidLesson, /01-broken\.md: lesson title must be present/)
  end

  it "rejects unknown frontmatter keys so typos do not pass silently" do
    write_lesson("01-typo.md", lesson_file(slug: "typo", order: 1, extra: "quizz: true\n"))

    expect { repository.catalog }
      .to raise_error(Course::InvalidLesson, /01-typo\.md: unknown frontmatter keys: quizz/)
  end
end
