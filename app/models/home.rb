class Home < ApplicationRecord
  belongs_to :user
  has_one_attached :document

  validate :acceptable_document

  private

  def acceptable_document
    return unless document.attached?

    return if document.content_type.in?(%w[application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet])

    errors.add(:document, 'must be an Excel file (.xls or .xlsx)')
  end
end
