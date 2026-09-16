class CustodyMovement < ApplicationRecord
  belongs_to :evidence
  belongs_to :from_user, class_name: "User", inverse_of: :outgoing_custody_movements, optional: true
  belongs_to :to_user, class_name: "User", inverse_of: :incoming_custody_movements
  belongs_to :performed_by, class_name: "User", inverse_of: :performed_custody_movements

  validates :transferred_at, :reason, presence: true
  validate :custodians_must_be_different

  before_update :prevent_changes
  before_destroy :prevent_changes

  private

  def custodians_must_be_different
    return if from_user_id.blank? || from_user_id != to_user_id

    errors.add(:to_user, "debe ser diferente del custodio actual")
  end

  def prevent_changes
    errors.add(:base, "El historial de custodia no puede modificarse ni eliminarse")
    throw :abort
  end
end
