class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid_now, -> { where("expires_at > ?", Time.current) }

  def self.issue!(user:)
    raw = SecureRandom.hex(32)
    create!(user: user, token_digest: Digest::SHA256.hexdigest(raw), expires_at: 24.hours.from_now)
    raw
  end
end
