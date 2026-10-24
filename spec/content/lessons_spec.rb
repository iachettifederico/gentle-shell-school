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

  it "proves the session runs in gentle-shell before recording the setup lessons" do
    %w[01-welcome 03-open-gentle-shell].each do |name|
      text = Rails.root.join("content/lessons/#{name}.md").read
      expect(text).to include("`gentle-shell --version` only proves the launcher is installed"), name
      expect(text).not_to include("If it prints version information, you are"), name
      expect(text).to include("GENTLE_SHELL_USER_PI_HOME"), name
      expect(text).not_to include("in your own tool list"), name
    end
  end

  it "teaches what scratch cleanup really removes and keeps" do
    text = Rails.root.join("content/lessons/07-sessions.md").read
    expect(text).to include("a live or quarantined subagent")
    expect(text).to include("empties the current session's scratch")
    expect(text).not_to include("It never removes a directory a live session still uses.")
  end
end
