module Staff
  class LoyaltyStampsController < BaseController
    def new
      @user = User.customer.find_by(email: params[:email]) if params[:email].present?
      @progress = @user ? LoyaltyStamp.progress_for(@user) : {}
    end

    def redeem
      stamp = LoyaltyStamp.find(params[:id])
      stamps = LoyaltyStamp.active.where(user: stamp.user, category: stamp.category).limit(LoyaltyStamp::STAMPS_PER_REWARD)
      if stamps.count >= LoyaltyStamp::STAMPS_PER_REWARD
        LoyaltyStamp.where(id: stamps.pluck(:id)).update_all(
          redeemed: true,
          redeemed_at: Time.current,
          redeemed_by_id: current_user.id,
          redemption_note: params[:note]
        )
        redirect_to new_staff_loyalty_stamp_path(email: stamp.user.email),
                    notice: "Redeemed: #{LoyaltyStamp.reward_label(stamp.category)}"
      else
        redirect_to new_staff_loyalty_stamp_path(email: stamp.user.email),
                    alert: "Not enough stamps to redeem yet."
      end
    end

    def create
      redirect_to new_staff_loyalty_stamp_path(email: params[:email])
    end
  end
end
