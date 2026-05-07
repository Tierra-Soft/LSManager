class Admin < ApplicationRecord
  has_secure_password

  enum :role, { general: 0, super_admin: 1 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
end
