class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :reviewable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :rating
      t.text :body

      t.timestamps
    end
  end
end
