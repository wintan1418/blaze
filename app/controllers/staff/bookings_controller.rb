module Staff
  class BookingsController < BaseController
    before_action :set_booking, only: [ :check_in, :cancel ]

    def index
      today = Time.current.all_day
      gaming_ids  = GamingSlot.where(starts_at: today).pluck(:id)
      cinema_ids  = Screening.where(starts_at: today).pluck(:id)

      scope = Booking.active.includes(:user, :bookable)
                     .where(
                       "(bookable_type = 'GamingSlot' AND bookable_id IN (?)) OR (bookable_type = 'Screening' AND bookable_id IN (?))",
                       gaming_ids, cinema_ids
                     )
                     .order("bookable_type, bookable_id")
      @bookings = scope.limit(100)
    end

    def check_in
      @booking.check_in!
      redirect_to staff_bookings_path, notice: "#{@booking.reference} checked in"
    end

    def cancel
      @booking.update(status: "cancelled")
      redirect_to staff_bookings_path, notice: "Booking cancelled."
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    end
  end
end
