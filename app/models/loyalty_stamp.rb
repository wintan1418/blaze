class LoyaltyStamp < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true, optional: true
  belongs_to :redeemed_by, class_name: "User", optional: true

  CATEGORIES = %w[gaming cinema food].freeze
  STAMPS_PER_REWARD = 5

  REWARDS = {
    "gaming" => "1 free 30-minute gaming session",
    "cinema" => "1 free cinema seat",
    "food"   => "₦2,500 off your next food order"
  }.freeze

  validates :category, inclusion: { in: CATEGORIES }
  validates :earned_at, presence: true

  scope :active, -> { where(redeemed: false) }
  scope :for_category, ->(cat) { where(category: cat) }

  # Award a stamp and return it. Idempotent per source record.
  def self.award_for!(user:, source:, category:, earned_at: Time.current)
    find_or_create_by!(user: user, source: source, category: category) do |s|
      s.earned_at = earned_at
    end
  end

  # How many stamps a user has in each category (unredeemed only).
  def self.progress_for(user)
    active.where(user: user).group(:category).count
  end

  # How many complete rewards are available for redemption in this category.
  def self.rewards_available(user, category)
    active.where(user: user, category: category).count / STAMPS_PER_REWARD
  end

  def self.reward_label(category)
    REWARDS.fetch(category.to_s, "Free reward")
  end
end
