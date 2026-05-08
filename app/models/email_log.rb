class EmailLog < ApplicationRecord
  belongs_to :student
  belongs_to :email_template, optional: true

  enum :status, { pending: 0, sent: 1, failed: 2 }

  scope :recent, -> { order(Arel.sql("COALESCE(sent_at, scheduled_at) DESC")) }

  def display_time
    scheduled_at || sent_at
  end
end
