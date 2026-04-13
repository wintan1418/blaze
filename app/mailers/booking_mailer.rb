class BookingMailer < ApplicationMailer
  default from: "Blaze Cafe <hello@blazecafe.ng>"

  def confirmation(booking)
    @booking = booking
    @user = booking.user
    @bookable = booking.bookable

    mail(
      to: @user.email,
      subject: "Blaze Cafe — Booking Confirmed (#{@booking.reference})"
    )
  end
end
