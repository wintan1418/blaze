class MenuCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :menu_items, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(position: :asc, name: :asc) }
end
