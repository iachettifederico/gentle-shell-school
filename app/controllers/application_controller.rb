class ApplicationController < ActionController::Base
  protect_from_forgery using: :header_or_legacy_token, with: :exception

  include LessonsAccess

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def labs_system
    @labs_system ||= Course::LabsSystem.new(
      repository: Course::FileLabRepository.new(directory: Rails.configuration.x.labs_directory)
    )
  end
end
