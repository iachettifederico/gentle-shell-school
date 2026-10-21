class LessonCompletion < ApplicationRecord
  belongs_to :student

  validates :lesson_slug, :completed_at, :source, presence: true
  validates :lesson_slug, uniqueness: { scope: :student_id }
end
