class ApplicationController < ActionController::Base
  protect_from_forgery using: :header_or_legacy_token, with: :exception

  include LessonsAccess

  around_action :with_request_locale

  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def with_request_locale(&)
    @current_locale = params[:locale].presence || "en"
    @locale_context = LocaleContext.new(locale: @current_locale, path: request.path, routes: main_app)
    I18n.with_locale(@current_locale, &)
  end

  def locale_context_locals
    { locale_context: @locale_context }
  end

  def lesson_prompt
    @lesson_prompt ||= LessonPrompt.new(origin: request.base_url, locale: @current_locale)
  end

  # The anonymous prompt for a lesson and the enrolled template the browser fills with its student ID.
  def prompt_locals(lesson, prefix)
    { "#{prefix}prompt": lesson_prompt.for(lesson, student_id: nil), "#{prefix}template": lesson_prompt.for(lesson) }
  end

  def labs_system
    @labs_system ||= Course::LabsSystem.new(
      repository: Course::FileLabRepository.new(directory: Rails.configuration.x.labs_directory)
    )
  end
end
