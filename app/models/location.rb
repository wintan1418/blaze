class Location < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :gaming_consoles, dependent: :destroy
  has_many :screens, dependent: :destroy
  has_many :gaming_slots, through: :gaming_consoles
  has_many :screenings, through: :screens
  has_one_attached :hero_image

  validates :name, :address, :city, presence: true

  scope :active, -> { where(active: true) }
end
