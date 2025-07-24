class Home < ApplicationRecord
  belongs_to :user
  has_one_attached :document

  validate :acceptable_document

  private

  def acceptable_document
    return unless document.attached?

    acceptable_types = %w[
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      text/csv
      text/plain
    ]

    return if document.content_type.in?(acceptable_types)

    errors.add(:document, 'must be a CSV or Excel file (.csv, .xls, or .xlsx)')
  end
end
