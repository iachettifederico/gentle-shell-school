class EnrollmentsController < ApplicationController
  include ProgressAccess
  include EnrollmentAccess

  rescue_from Course::EnrollmentNotFound, with: :not_found
  rescue_from Course::EnrollmentExpired, with: :expired
  rescue_from Course::EnrollmentAlreadyClaimed, with: :already_used

  def show
    enrollment = enrollment_system.status(params[:code])
    return already_used if enrollment.status == "enrolled"

    render :show, locals: locale_context_locals.merge(enrollment: enrollment)
  end

  def create
    enrollment = enrollment_system.claim(params[:code])
    render :confirmation, locals: locale_context_locals.merge(enrollment: enrollment)
  end

  private

  def not_found
    render :not_found, status: :not_found, locals: locale_context_locals
  end

  def expired
    render :expired, status: :gone, locals: locale_context_locals
  end

  def already_used
    render :already_used, locals: locale_context_locals
  end
end
