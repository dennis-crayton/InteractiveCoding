class CodeExample < ApplicationRecord
  belongs_to :user_page

  validates :title, presence: true
end
