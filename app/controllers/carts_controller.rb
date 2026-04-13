class CartsController < ApplicationController
  before_action :load_cart

  def show
    @cart_lines = @cart.items
    @locations = Location.active
  end

  # POST /cart/add
  def add
    item = MenuItem.friendly.find(params[:menu_item_id])
    qty = (params[:qty] || 1).to_i
    @cart.add(item, qty: qty)
    redirect_back(fallback_location: cart_path, notice: "Added #{item.name} to your cart")
  end

  # PATCH /cart/update
  def update
    @cart.set(params[:menu_item_id], params[:qty])
    redirect_to cart_path
  end

  # DELETE /cart/remove/:menu_item_id
  def remove
    @cart.remove(params[:menu_item_id])
    redirect_to cart_path, notice: "Removed from cart"
  end

  # DELETE /cart
  def destroy
    @cart.clear!
    redirect_to cart_path, notice: "Cart cleared"
  end

  private

  def load_cart
    @cart = Cart.new(session)
  end
end
