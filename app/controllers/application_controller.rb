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

  def labs_system
    @labs_system ||= Course::LabsSystem.new(
      repository: Course::FileLabRepository.new(directory: Rails.configuration.x.labs_directory)
    )
  end
end
