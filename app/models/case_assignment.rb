class CaseAssignment < ApplicationRecord
  belongs_to :case
  belongs_to :user

  validates :user_id, uniqueness: { scope: :case_id }
  validate :user_must_be_an_analyst

  private

  def user_must_be_an_analyst
    errors.add(:user, "debe ser analista") if user && !user.analyst?
  end
end
