class PaymentsController < ApplicationController
  before_action :authenticate_user!, except: [ :webhook ]
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  # GET /payments/callback?reference=BLZ-PAY-...
  # Paystack redirects here after the user finishes on the checkout page.
  def callback
    reference = params[:reference] || params[:trxref]
    @payment = Payment.find_by(reference: reference)

    unless @payment
      flash[:alert] = "Payment reference not found."
      redirect_to root_path and return
    end

    if @payment.success?
      redirect_to success_payment_path(@payment) and return
    end

    verify_and_finalize(@payment)

    if @payment.success?
      redirect_to success_payment_path(@payment)
    else
      redirect_to failed_payment_path(@payment)
    end
  end

  # GET /payments/:id/success
  def success
    @payment = current_user.payments.find(params[:id])
    @booking = @payment.payable if @payment.payable.is_a?(Booking)
  end

  # GET /payments/:id/failed
  def failed
    @payment = current_user.payments.find(params[:id])
    @booking = @payment.payable if @payment.payable.is_a?(Booking)
  end

  # POST /payments/webhook
  # Paystack webhook — server-to-server notification. Source of truth.
  def webhook
    raw_body = request.raw_post
    signature = request.headers["X-Paystack-Signature"]

    unless PaystackClient.valid_webhook_signature?(raw_body, signature)
      head :unauthorized and return
    end

    event = JSON.parse(raw_body) rescue {}
    if event["event"] == "charge.success"
      ref = event.dig("data", "reference")
      payment = Payment.find_by(provider_reference: ref) || Payment.find_by(reference: ref)
      verify_and_finalize(payment) if payment && !payment.success?
    end

    head :ok
  end

  private

  # Verifies a payment with Paystack and, if successful, marks the payment and booking as paid.
  # Idempotent — safe to call multiple times.
  def verify_and_finalize(payment)
    return if payment.success?

    result = PaystackClient.verify_transaction(payment.reference)

    if result[:success] && result[:amount_kobo] >= payment.amount_kobo
      Booking.transaction do
        payment.mark_success!(
          provider_reference: result[:provider_reference],
          channel: result[:channel],
          paid_at: result[:paid_at] || Time.current,
          metadata: { paystack: result[:raw] }
        )
        if payment.payable.is_a?(Booking)
          payment.payable.mark_paid!(at: result[:paid_at] || Time.current)
          # Reserve the slot so it's not double-booked
          if payment.payable.bookable.is_a?(GamingSlot)
            payment.payable.bookable.update(status: "reserved")
          end
        end
      end
    else
      payment.mark_failed!(reason: result[:status] || "verification_failed")
    end
  rescue PaystackClient::Error => e
    Rails.logger.error("[Paystack] verify failed: #{e.message}")
    payment.mark_failed!(reason: e.message)
  end
end

