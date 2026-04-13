class PagesController < ApplicationController
  def home
    @featured_items = MenuItem.available.featured.includes(:menu_category).limit(6)
    @upcoming_screenings = Screening.upcoming.available.includes(:screen).limit(4)
    @locations = Location.active
    @categories = MenuCategory.ordered
    @menu_strip = MenuItem.available.includes(:menu_category).limit(20)
    @hero_slides = HeroSlide.active.ordered
  end

  def about; end
  def contact; end
end
