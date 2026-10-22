require "rails_helper"

RSpec.describe "Course configuration" do
  around do |example|
    original_directory = Rails.configuration.x.lessons_directory
    example.run
  ensure
    Rails.configuration.x.lessons_directory = original_directory
  end

  it "uses content/lessons by default" do
    configure_lessons_directory(environment: "development", course: nil)

    expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/lessons"))
  end

  it "uses the demo lessons only for COURSE=demo in development" do
    configure_lessons_directory(environment: "development", course: "demo")

    expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/demo/lessons"))
  end

  %w[test production].each do |environment|
    it "ignores COURSE=demo in #{environment}" do
      configure_lessons_directory(environment: environment, course: "demo")

      expect(Rails.configuration.x.lessons_directory).to eq(Rails.root.join("content/lessons"))
    end
  end

  private

  def configure_lessons_directory(environment:, course:)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("COURSE").and_return(course)

    load Rails.root.join("config/initializers/course.rb")
  end
end
