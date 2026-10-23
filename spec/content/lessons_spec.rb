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

  it "ships a discoverable Pi course skill and prompt" do
    package = JSON.parse(Rails.root.join("package.json").read)
    skill_path = Rails.root.join("agent/skills/gentle-shell-school/SKILL.md")

    expect(package.dig("pi", "skills")).to eq([ "./agent/skills" ])
    expect(package.dig("pi", "prompts")).to eq([ "./agent/prompts/*.md" ])
    expect(skill_path).to exist
    expect(skill_path.read).to match(/^---\nname: gentle-shell-school\ndescription: .+\n/m)
    expect(Rails.root.join("agent/prompts/school.md")).to exist
  end

  it "teaches the gentle-shell tutor install up front and its optional removal at the end, in every language" do
    source = "git:github.com/iachettifederico/gentle-shell-school"
    [ "", "es/", "es-AR/" ].each do |locale|
      welcome = Rails.root.join("content/lessons/#{locale}01-welcome.md").read
      capstone = Rails.root.join("content/lessons/#{locale}29-capstone.md").read

      expect(welcome).to include("gentle-shell install #{source}"), "#{locale}01-welcome.md"
      expect(welcome).to include("pi install #{source}"), "#{locale}01-welcome.md"
      expect(capstone).to include("gentle-shell remove #{source}"), "#{locale}29-capstone.md"
      expect(capstone).to include("pi remove #{source}"), "#{locale}29-capstone.md"
    end
  end
end
