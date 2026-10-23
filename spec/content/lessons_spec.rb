require "rails_helper"

# Guards the shipped course content: every lesson file must load.
RSpec.describe "Course content" do
  it "loads every lesson in content/lessons" do
    system = Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.root.join("content/lessons"))
    )

    expect(system.lessons).not_to be_empty
    expect(system.lessons.first.slug).to eq("welcome")
    expect(system.lessons.map(&:module_name)).to all(match(/\S/))
  end

  it "starts with the any-agent getting started lessons and has contiguous orders" do
    system = Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.root.join("content/lessons"))
    )

    expect(system.lessons.first(3).map(&:slug)).to eq(%w[welcome install-gentle-shell open-gentle-shell])
    expect(system.lessons.first(3).map(&:module_name)).to all(eq("Getting started"))
    expect(system.lessons.map(&:order)).to eq((1..29).to_a)
  end

  it "loads the demo lessons in order" do
    system = Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.root.join("content/demo/lessons"))
    )

    expect(system.lessons.map(&:module_name)).to all(eq("Demo"))
    expect(system.lessons.map(&:slug)).to eq(%w[demo-welcome demo-quiz-and-check demo-feedback])
  end

  it "loads every real and demo lab" do
    real_labs = Course::LabsSystem.new(
      repository: Course::FileLabRepository.new(directory: Rails.root.join("content/labs"))
    )
    demo_labs = Course::LabsSystem.new(
      repository: Course::FileLabRepository.new(directory: Rails.root.join("content/demo/labs"))
    )

    expect(real_labs.labs.map(&:slug))
      .to eq(%w[explore-handoff feature-document red-green work-unit-commits write-a-skill])
    expect(demo_labs.labs.map(&:slug)).to eq([ "demo-hello" ])
  end

  it "teaches a single course path in every language" do
    retired = [
      "/school", "git:github.com/iachettifederico/gentle-shell-school", "api/enrollments", "enrollUrl",
      "student ID is <id>", "hand-off prompt", "any coding agent",
    ]
    Rails.root.glob("content/lessons/{,es/,es-AR/}*.md").each do |path|
      text = File.read(path)
      retired.each { |phrase| expect(text).not_to include(phrase), "#{path} still mentions #{phrase.inspect}" }
    end

    open_lesson = Rails.root.join("content/lessons/03-open-gentle-shell.md").read
    expect(open_lesson).to include("record `welcome`, `install-gentle-shell`, and `open-gentle-shell`")
    welcome = Rails.root.join("content/lessons/01-welcome.md").read
    expect(welcome).to include("`next.prompt` of `open-gentle-shell`")
  end
end
