class User < ApplicationRecord
  has_secure_password
  # 24 characters of base58, generated on create. What a script sends to reach
  # an engine's API. Regenerating it is the whole of revocation: the old token
  # stops working the moment the new one is written, and nothing else about
  # the account changes.
  has_secure_token :api_token
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  # Long enough that guessing is not a shortcut, and nothing else. No required
  # digit, no required symbol: those rules produce Passw0rd! and a sticky note.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
