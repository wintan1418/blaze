module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: [ :show, :update ]

    def index
      scope = Booking.includes(:user, :bookable).order(created_at: :desc)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @pagy, @bookings = pagy(scope, limit: 25)
    end

    def show; end

    def update
      if @booking.update(booking_params)
        redirect_to admin_bookings_path, notice: "Booking updated."
      else
        redirect_to admin_booking_path(@booking), alert: "Could not update."
      end
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    end

    def booking_params
      params.require(:booking).permit(:status, :notes)
    end
  end
end
