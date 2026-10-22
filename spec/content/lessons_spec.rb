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
end
