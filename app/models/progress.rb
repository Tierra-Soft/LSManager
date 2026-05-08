class Progress < ApplicationRecord
  belongs_to :student
  belongs_to :lesson

  enum :status, { not_started: 0, in_progress: 1, completed: 2 }

  validates :student_id, uniqueness: { scope: :lesson_id }
  validates :score, numericality: { greater_than_or_equal_to: 0 }

  before_save :auto_set_status

  def completion_rate
    return 0 if lesson.total_score <= 0
    [(score.to_f / lesson.total_score * 100).round, 100].min
  end

  private

  def auto_set_status
    total = lesson.total_score
    s = score.to_i
    if s >= total
      self.status = :completed
      self.completed_at ||= Time.current
    elsif s > 0
      self.status = :in_progress
      self.completed_at = nil
    else
      self.status = :not_started
      self.completed_at = nil
    end
  end
end
