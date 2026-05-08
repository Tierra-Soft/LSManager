class Lesson < ApplicationRecord
  belongs_to :course
  has_many :progresses, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :total_score, presence: true, numericality: { greater_than: 0 }
end
