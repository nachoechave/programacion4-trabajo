class Evidence < ApplicationRecord
  enum :status, { registered: 0, in_custody: 1, under_analysis: 2, archived: 3 }

  belongs_to :case
  belongs_to :evidence_type
  belongs_to :current_custodian, class_name: "User", inverse_of: :custodied_evidences
  has_many :custody_movements, dependent: :restrict_with_error
  has_many_attached :files

  validates :code, :name, :collected_at, presence: true
  validates :code, uniqueness: true
  validate :custodian_must_be_active
  validate :attached_files_are_safe

  private

  def custodian_must_be_active
    errors.add(:current_custodian, "debe estar activo") if current_custodian && !current_custodian.active?
  end

  def attached_files_are_safe
    return unless files.attached?

    files.each do |file|
      if file.byte_size > 25.megabytes
        errors.add(:files, "no pueden superar 25 MB por archivo")
      end
      unless %w[application/pdf image/png image/jpeg text/plain application/octet-stream].include?(file.content_type)
        errors.add(:files, "deben ser PDF, JPG, PNG, TXT o binarios")
      end
    end
  end
end
