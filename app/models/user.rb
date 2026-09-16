class User < ApplicationRecord
  has_secure_password

  enum :role, { admin: 0, analyst: 1 }

  has_many :case_assignments, dependent: :destroy
  has_many :assigned_cases, through: :case_assignments, source: :case
  has_many :custodied_evidences,
           class_name: "Evidence",
           foreign_key: :current_custodian_id,
           inverse_of: :current_custodian,
           dependent: :restrict_with_error
  has_many :outgoing_custody_movements,
           class_name: "CustodyMovement",
           foreign_key: :from_user_id,
           inverse_of: :from_user,
           dependent: :restrict_with_error
  has_many :incoming_custody_movements,
           class_name: "CustodyMovement",
           foreign_key: :to_user_id,
           inverse_of: :to_user,
           dependent: :restrict_with_error
  has_many :performed_custody_movements,
           class_name: "CustodyMovement",
           foreign_key: :performed_by_id,
           inverse_of: :performed_by,
           dependent: :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active, -> { where(active: true) }
end
