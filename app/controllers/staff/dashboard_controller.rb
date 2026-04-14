module Staff
  class DashboardController < BaseController
    def index
      today = Time.current.all_day

      @stats = {
        orders_today:      Order.where(created_at: today).count,
        orders_active:     Order.where(status: %w[pending preparing ready]).count,
        bookings_upcoming: bookings_today.count,
        offline_today:     OfflineSale.where(sold_at: today).count,
        offline_revenue:   OfflineSale.where(sold_at: today).sum(:total_kobo)
      }

      @active_orders     = Order.where(status: %w[pending preparing ready]).includes(:user, :order_items).order(:created_at).limit(8)
      @upcoming_bookings = bookings_today.includes(:user, :bookable).limit(10)
    end

    private

    # Bookings for today (gaming slots starting today + cinema screenings starting today)
    def bookings_today
      today = Time.current.all_day
      gaming_ids = GamingSlot.where(starts_at: today).pluck(:id)
      cinema_ids = Screening.where(starts_at: today).pluck(:id)
      Booking.active.where(
        "(bookable_type = 'GamingSlot' AND bookable_id IN (?)) OR (bookable_type = 'Screening' AND bookable_id IN (?))",
        gaming_ids, cinema_ids
      ).order(:created_at)
    end
  end
end
