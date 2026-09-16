class Case < ApplicationRecord
  enum :status, { open: 0, closed: 1 }

  has_many :case_assignments, dependent: :destroy
  has_many :analysts, through: :case_assignments, source: :user
  has_many :evidences, dependent: :restrict_with_error

  validates :code, :title, :opened_at, presence: true
  validates :code, uniqueness: true
end
