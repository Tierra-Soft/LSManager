class Progress < ApplicationRecord
  belongs_to :student
  belongs_to :lesson

  enum :status, { not_started: 0, in_progress: 1, completed: 2 }

  validates :student_id, uniqueness: { scope: :lesson_id }

  before_save :set_completed_at

  private

  def set_completed_at
    self.completed_at = Time.current if completed? && completed_at.nil?
  end
end
