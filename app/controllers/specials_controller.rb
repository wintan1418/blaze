class SpecialsController < ApplicationController
  def index
    @specials = Special.active.ordered
  end

  def show
    @special = Special.friendly.find(params[:id])
  end

  # POST /specials/:id/claim — bumps the slots_claimed counter and sends the
  # user to the right next step (cart, booking, etc).
  def claim
    @special = Special.friendly.find(params[:id])
    if @special.sold_out?
      redirect_to specials_path, alert: "That special just sold out. Sorry!"
      return
    end

    @special.claim!

    case @special.kind
    when "food", "drink"
      if @special.menu_item
        Cart.new(session).add(@special.menu_item, qty: 1)
        redirect_to cart_path, notice: "#{@special.name} added to cart — checkout to claim"
      else
        redirect_to menu_items_path, notice: "Claimed #{@special.name}. Mention this at the counter!"
      end
    when "cinema"
      if @special.screening
        redirect_to new_screening_booking_path(@special.screening), notice: "Claimed #{@special.name} — complete your booking"
      else
        redirect_to screenings_path, notice: "Claimed #{@special.name}!"
      end
    when "gaming"
      redirect_to gaming_slots_path, notice: "Claimed #{@special.name} — pick a slot"
    else
      redirect_to specials_path, notice: "Claimed #{@special.name}"
    end
  end
end
