class EnrollmentsController < ApplicationController
  include ProgressAccess
  include EnrollmentAccess

  rescue_from Course::EnrollmentNotFound, with: :not_found
  rescue_from Course::EnrollmentExpired, with: :expired
  rescue_from Course::EnrollmentAlreadyClaimed, with: :already_used

  def show
    enrollment = enrollment_system.status(params[:code])
    return already_used if enrollment.status == "enrolled"

    render :show, locals: { enrollment: enrollment }
  end

  def create
    enrollment = enrollment_system.claim(params[:code])
    render :confirmation, locals: { enrollment: enrollment }
  end

  private

  def not_found
    render :not_found, status: :not_found
  end

  def expired
    render :expired, status: :gone
  end

  def already_used
    render :already_used
  end
end
