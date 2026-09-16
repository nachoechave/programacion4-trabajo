class Evidence < ApplicationRecord
  enum :status, { registered: 0, in_custody: 1, under_analysis: 2, archived: 3 }

  belongs_to :case
  belongs_to :evidence_type
  belongs_to :current_custodian, class_name: "User", inverse_of: :custodied_evidences
  has_many :custody_movements, dependent: :restrict_with_error

  validates :code, :name, :collected_at, presence: true
  validates :code, uniqueness: true
  validate :custodian_must_be_active

  private

  def custodian_must_be_active
    errors.add(:current_custodian, "debe estar activo") if current_custodian && !current_custodian.active?
  end
end
