# Plain-text entry point for agents: what the school is and how to teach it.
# The URL fixes the language: /llms.txt, /es/llms.txt, or /es-AR/llms.txt.
class LlmsController < ApplicationController
  LANGUAGES = {
    "en"    => %w[English English],
    "es"    => [ "Spanish", "neutral Latin American Spanish with \"tú\"" ],
    "es-AR" => [ "Spanish (Argentina)", "Rioplatense Spanish with voseo" ],
  }.freeze
  EXAMPLE_LESSON = Data.define(:title, :slug).new(title: "<title>", slug: "<slug>")

  def show
    render plain: render_to_string(template: "llms/show", formats: [ :text ], locals: llms_locals)
  end

  private

  def llms_locals
    prompt = LessonPrompt.new(origin: request.base_url, locale: @current_locale)
    language, teaching = LANGUAGES.fetch(@current_locale)
    {
      origin: request.base_url, locale: @current_locale, language: language, teaching_language: teaching,
      llms_url: prompt.llms_url, example_prompt: prompt.for(EXAMPLE_LESSON, student_id: "<id>"),
    }
  end
end
