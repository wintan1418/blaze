module GamingSlots
  class BookingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_slot

    def new
      @booking = @slot.bookings.build(seats: 1)
    end

    def create
      @booking = @slot.bookings.build(booking_params)
      @booking.user = current_user

      if @slot.taken?
        flash.now[:alert] = "This slot has already been booked."
        render :new, status: :unprocessable_entity and return
      end

      if @booking.save
        @slot.update(status: "reserved")
        redirect_to booking_path(@booking), notice: "Slot locked in. Blaze awaits."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_slot
      @slot = GamingSlot.find(params[:gaming_slot_id])
    end

    def booking_params
      params.require(:booking).permit(:seats, :notes)
    end
  end
end
