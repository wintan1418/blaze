class MenuItem < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :menu_category
  has_one_attached :image
  has_many :reviews, as: :reviewable, dependent: :destroy

  validates :name, presence: true
  validates :price_kobo, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(available: true) }
  scope :featured, -> { where(featured: true) }

  def price_naira
    price_kobo.to_i / 100.0
  end

  def price_naira=(value)
    self.price_kobo = (value.to_f * 100).round
  end
end
