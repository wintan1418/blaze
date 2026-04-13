class HeroSlide < ApplicationRecord
  has_one_attached :image

  validates :kind, :title, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  # Returns the URL to render — prefers attached upload, falls back to image_url string.
  def display_image_url
    if image.attached?
      Rails.application.routes.url_helpers.url_for(image)
    else
      image_url
    end
  end
end
