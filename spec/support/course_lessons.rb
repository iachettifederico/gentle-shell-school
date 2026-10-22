require_relative "../../app/domain/course/invalid_lesson"
require_relative "../../app/domain/course/quiz_instructions"
require_relative "../../app/domain/course/lesson_content"
require_relative "../../app/domain/course/lesson"
require_relative "../../app/domain/course/catalog"

# Builds domain lessons for specs without loading Rails.
module CourseLessons
  def build_lesson(slug: "welcome", order: 1, quiz: false, module_name: nil, **content)
    Course::Lesson.new(
      slug: slug, order: order, quiz: quiz, module_name: module_name, content: build_lesson_content(**content)
    )
  end

  def build_lesson_content(**overrides)
    Course::LessonContent.new(
      title:              "Welcome",
      description:        "Meet the course.",
      agent_instructions: "Verify the student is set up.",
      body:               "# Hello",
      **overrides
    )
  end
end
