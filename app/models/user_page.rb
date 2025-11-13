class UserPage < ApplicationRecord
  belongs_to :language, optional: true

  has_many :sections, dependent: :destroy
  has_many :code_examples, dependent: :destroy
  has_many :exercises, dependent: :destroy

  accepts_nested_attributes_for :sections, :code_examples, :exercises, allow_destroy: true

  validates :title, presence: true
end
