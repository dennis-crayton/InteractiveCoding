class Language < ApplicationRecord
  has_many :user_pages, dependent: :nullify

  validates :name, presence: true
end
