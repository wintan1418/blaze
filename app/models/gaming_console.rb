class GamingConsole < ApplicationRecord
  belongs_to :location
  has_many :gaming_slots, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :location_id }
  validates :console_type, presence: true

  scope :active, -> { where(active: true) }

  def label
    "#{console_type} ##{number}"
  end
end
