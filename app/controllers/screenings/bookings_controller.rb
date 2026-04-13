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

      unless @booking.save
        render :new, status: :unprocessable_entity and return
      end

      if PaystackClient.configured?
        begin
          payment = create_payment_for(@booking)
          redirect_to payment.authorization_url, allow_other_host: true
        rescue PaystackClient::Error => e
          flash[:alert] = "Payment could not be started: #{e.message}"
          redirect_to booking_path(@booking)
        end
      else
        redirect_to booking_path(@booking), notice: "Seats reserved. Pay at the counter on arrival."
      end
    end

    private

    def set_screening
      @screening = Screening.friendly.find(params[:screening_id])
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
          bookable_type: "Screening",
          seats: booking.seats,
          user_id: current_user.id
        }
      )
      payment.update!(authorization_url: result[:authorization_url])
      payment
    end
  end
end
