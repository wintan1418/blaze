class OrderMailer < ApplicationMailer
  default from: "Blaze Cafe <hello@blazecafe.ng>"

  SUBJECTS = {
    order_received:        "Blaze Cafe — we got your order (%{ref})",
    order_paid:            "Blaze Cafe — payment confirmed (%{ref})",
    order_ready:           "Blaze Cafe — your order is ready (%{ref})",
    order_out_for_delivery: "Blaze Cafe — your delivery is on the way (%{ref})",
    order_delivered:       "Blaze Cafe — order delivered (%{ref})"
  }.freeze

  def status_update
    @order = params[:order]
    @event = params[:event].to_sym
    @user  = @order.user

    subject_template = SUBJECTS[@event] || "Blaze Cafe — order update (%{ref})"
    mail(
      to: @user.email,
      subject: subject_template % { ref: @order.reference }
    )
  end
end
