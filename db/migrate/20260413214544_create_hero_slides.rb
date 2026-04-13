class CreateHeroSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :hero_slides do |t|
      t.integer :position,  default: 0, null: false
      t.string  :image_url                              # external URL fallback
      t.string  :kind,      null: false                 # eyebrow, e.g. "Now serving"
      t.string  :title,     null: false                 # main caption
      t.string  :meta                                   # sub-caption, e.g. "₦2,500 · smoke"
      t.boolean :active,    default: true, null: false

      t.timestamps
    end
    add_index :hero_slides, :position
    add_index :hero_slides, :active
  end
end
