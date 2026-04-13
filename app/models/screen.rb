class Screen < ApplicationRecord
  belongs_to :location
  has_many :screenings, dependent: :destroy

  validates :name, presence: true
  validates :capacity, numericality: { greater_than: 0 }
end
