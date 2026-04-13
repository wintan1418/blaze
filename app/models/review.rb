class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
  belongs_to :user

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :body, presence: true, length: { maximum: 2000 }
end
