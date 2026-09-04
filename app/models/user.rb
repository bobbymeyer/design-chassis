class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  # Long enough that guessing is not a shortcut, and nothing else. No required
  # digit, no required symbol: those rules produce Passw0rd! and a sticky note.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
