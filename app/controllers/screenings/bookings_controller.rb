module Screenings
  class BookingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_screening

    def new
      @booking = @screening.bookings.build(seats: 1)
    end

    def create
      @booking = @screening.bookings.build(booking_params)
      @booking.user = current_user

      if @screening.sold_out? || @booking.seats.to_i > @screening.seats_remaining
        flash.now[:alert] = "Not enough seats left for this screening."
        render :new, status: :unprocessable_entity and return
      end

      if @booking.save
        redirect_to booking_path(@booking), notice: "Seats locked. See you at the screen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_screening
      @screening = Screening.friendly.find(params[:screening_id])
    end

    def booking_params
      params.require(:booking).permit(:seats, :notes)
    end
  end
end
