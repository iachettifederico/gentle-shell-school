# The copyable prompt that starts one lesson in the student's agent. The lesson
# page and the lessons API both use it, so the site and the agent always hand
# out the same words. The language lives in the llms.txt URL it points to.
class LessonPrompt
  STUDENT_PLACEHOLDER = "{studentId}".freeze

  def initialize(origin:, locale:)
    @origin = origin
    @locale = locale
  end

  # Pass student_id: nil for a student who has not enrolled.
  def for(lesson, student_id: STUDENT_PLACEHOLDER)
    I18n.with_locale(@locale) do
      sentences = [
        I18n.t("prompt.lesson", title: lesson.title, slug: lesson.slug), I18n.t("prompt.fetch", llms_url: llms_url),
      ]
      sentences.unshift(I18n.t("prompt.enrolled", student_id: student_id)) if student_id
      sentences.join(" ")
    end
  end

  def llms_url
    @locale == "en" ? "#{@origin}/llms.txt" : "#{@origin}/#{@locale}/llms.txt"
  end
end
