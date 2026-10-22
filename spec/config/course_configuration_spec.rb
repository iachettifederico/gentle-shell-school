require "rails_helper"

RSpec.describe "Course configuration" do
  around do |example|
    original_lessons_directory = Rails.configuration.x.lessons_directory
    original_labs_directory = Rails.configuration.x.labs_directory
    example.run
  ensure
    Rails.configuration.x.lessons_directory = original_lessons_directory
    Rails.configuration.x.labs_directory = original_labs_directory
  end

  it "uses content directories by default" do
    configure_course_directories(environment: "development", course: nil)

    expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/lessons"))
    expect(Rails.configuration.x.labs_directory).to eq(Rails.root.join("content/labs"))
  end

  it "uses the demo directories only for COURSE=demo in development" do
    configure_course_directories(environment: "development", course: "demo")

    expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/demo/lessons"))
    expect(Rails.configuration.x.labs_directory).to eq(Rails.root.join("content/demo/labs"))
  end

  %w[test production].each do |environment|
    it "ignores COURSE=demo in #{environment}" do
      configure_course_directories(environment: environment, course: "demo")

      expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/lessons"))
      expect(Rails.configuration.x.labs_directory).to eq(Rails.root.join("content/labs"))
    end
  end

  private

  def configure_course_directories(environment:, course:)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("COURSE").and_return(course)

    load Rails.root.join("config/initializers/course.rb")
  end
end
