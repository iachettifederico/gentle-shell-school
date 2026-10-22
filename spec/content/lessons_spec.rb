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

  it "loads the demo lessons in order" do
    system = Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.root.join("content/demo/lessons"))
    )

    expect(system.lessons.map(&:module_name)).to all(eq("Demo"))
    expect(system.lessons.map(&:slug)).to eq(%w[demo-welcome demo-quiz-and-check demo-feedback])
  end
end
