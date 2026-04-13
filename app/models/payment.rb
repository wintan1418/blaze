class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :user

  STATUSES = %w[pending success failed abandoned].freeze

  validates :reference, presence: true, uniqueness: true
  validates :amount_kobo, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  before_validation :generate_reference, on: :create

  scope :successful, -> { where(status: "success") }
  scope :recent, -> { order(created_at: :desc) }

  def success?  = status == "success"
  def pending?  = status == "pending"
  def failed?   = status == "failed"

  def mark_success!(provider_reference:, channel: nil, paid_at: Time.current, metadata: {})
    update!(
      status: "success",
      provider_reference: provider_reference,
      channel: channel,
      paid_at: paid_at,
      metadata: self.metadata.merge(metadata || {})
    )
  end

  def mark_failed!(reason: nil)
    update!(status: "failed", metadata: metadata.merge(failure_reason: reason))
  end

  private

  def generate_reference
    return if reference.present?
    loop do
      self.reference = "BLZ-PAY-#{SecureRandom.alphanumeric(10).upcase}"
      break unless Payment.exists?(reference: reference)
    end
  end
end
