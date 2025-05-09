class Home < ApplicationRecord
  belongs_to :user
  has_one_attached :document
end
