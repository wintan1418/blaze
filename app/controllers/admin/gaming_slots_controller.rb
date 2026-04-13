module Admin
  class GamingSlotsController < BaseController
    before_action :set_slot, only: [ :edit, :update, :destroy ]

    def index
      scope = GamingSlot.includes(gaming_console: :location).order(:starts_at)
      scope = scope.where("starts_at >= ?", Time.current) if params[:filter] != "all"
      @pagy, @slots = pagy(scope, limit: 30)
    end

    def new
      @slot = GamingSlot.new
    end

    def create
      @slot = GamingSlot.new(slot_params)
      if @slot.save
        redirect_to admin_gaming_slots_path, notice: "Slot created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @slot.update(slot_params)
        redirect_to admin_gaming_slots_path, notice: "Slot updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @slot.destroy
      redirect_to admin_gaming_slots_path, notice: "Slot deleted."
    end

    # POST /admin/gaming_slots/generate
    # Bulk-generate the next N days of 30-minute slots for all active consoles.
    def generate
      days = params[:days].to_i.clamp(1, 30)
      price_kobo = (params[:price_naira].to_f * 100).round.clamp(0, 10_000_000)
      created = 0

      GamingConsole.active.find_each do |console|
        days.times do |day_offset|
          base = Time.zone.now.beginning_of_day + day_offset.days + 10.hours
          16.times do |i|
            starts = base + (i * 30).minutes
            next if starts < Time.current
            slot = GamingSlot.find_or_initialize_by(gaming_console: console, starts_at: starts)
            if slot.new_record?
              slot.assign_attributes(duration_minutes: 30, status: "open", price_kobo: price_kobo)
              created += 1 if slot.save
            end
          end
        end
      end

      redirect_to admin_gaming_slots_path, notice: "Generated #{created} new slots across #{days} days."
    end

    private

    def set_slot
      @slot = GamingSlot.find(params[:id])
    end

    def slot_params
      params.require(:gaming_slot).permit(:gaming_console_id, :starts_at, :duration_minutes, :status, :price_kobo)
    end
  end
end
