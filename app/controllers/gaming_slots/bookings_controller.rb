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

      unless @booking.save
        render :new, status: :unprocessable_entity and return
      end

      # Kick off Paystack checkout if keys are configured, otherwise fall back
      # to "pay at counter" mode (booking created as unpaid pending).
      if PaystackClient.configured?
        begin
          payment = create_payment_for(@booking)
          redirect_to payment.authorization_url, allow_other_host: true
        rescue PaystackClient::Error => e
          flash[:alert] = "Payment could not be started: #{e.message}"
          redirect_to booking_path(@booking)
        end
      else
        redirect_to booking_path(@booking), notice: "Slot reserved. Pay at the counter on arrival."
      end
    end

    private

    def set_slot
      @slot = GamingSlot.find(params[:gaming_slot_id])
    end

    def booking_params
      params.require(:booking).permit(:seats, :notes)
    end

    def create_payment_for(booking)
      payment = booking.payments.create!(
        user: current_user,
        amount_kobo: booking.total_price_kobo,
        status: "pending"
      )
      result = PaystackClient.initialize_transaction(
        email: current_user.email,
        amount_kobo: booking.total_price_kobo,
        reference: payment.reference,
        callback_url: payments_callback_url,
        metadata: {
          booking_ref: booking.reference,
          bookable_type: "GamingSlot",
          seats: booking.seats,
          user_id: current_user.id
        }
      )
      payment.update!(authorization_url: result[:authorization_url])
      payment
    end
  end
end
