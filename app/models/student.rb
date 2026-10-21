class Student < ApplicationRecord
  has_many :lesson_completions, dependent: :destroy

  validates :public_id, presence: true, uniqueness: true
end
