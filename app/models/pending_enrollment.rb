class PendingEnrollment < ApplicationRecord
  belongs_to :student, optional: true

  validates :code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending enrolled] }
end
