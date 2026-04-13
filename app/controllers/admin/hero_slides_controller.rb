module Admin
  class HeroSlidesController < BaseController
    before_action :set_slide, only: [ :edit, :update, :destroy, :toggle, :move_up, :move_down ]

    def index
      @slides = HeroSlide.ordered
    end

    def new
      @slide = HeroSlide.new(position: (HeroSlide.maximum(:position) || 0) + 1, active: true)
    end

    def create
      @slide = HeroSlide.new(slide_params)
      if @slide.save
        redirect_to admin_hero_slides_path, notice: "Slide added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @slide.update(slide_params)
        redirect_to admin_hero_slides_path, notice: "Slide updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @slide.destroy
      redirect_to admin_hero_slides_path, notice: "Slide removed."
    end

    def toggle
      @slide.update(active: !@slide.active)
      redirect_to admin_hero_slides_path
    end

    def move_up
      swap_with(HeroSlide.where("position < ?", @slide.position).order(position: :desc).first)
    end

    def move_down
      swap_with(HeroSlide.where("position > ?", @slide.position).order(:position).first)
    end

    private

    def swap_with(other)
      if other
        HeroSlide.transaction do
          my_pos = @slide.position
          @slide.update!(position: other.position)
          other.update!(position: my_pos)
        end
      end
      redirect_to admin_hero_slides_path
    end

    def set_slide
      @slide = HeroSlide.find(params[:id])
    end

    def slide_params
      params.require(:hero_slide).permit(:position, :image_url, :kind, :title, :meta, :active, :image)
    end
  end
end
