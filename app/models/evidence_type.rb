class EvidenceType < ApplicationRecord
  has_many :evidences, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
