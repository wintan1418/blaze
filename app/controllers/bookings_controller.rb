class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :cancel ]

  def index
    @pagy, @bookings = pagy(current_user.bookings.includes(:bookable).recent, limit: 15)
  end

  def show; end

  def cancel
    if %w[pending confirmed].include?(@booking.status)
      @booking.cancel!
      redirect_to bookings_path, notice: "Booking cancelled."
    else
      redirect_to bookings_path, alert: "This booking cannot be cancelled."
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
