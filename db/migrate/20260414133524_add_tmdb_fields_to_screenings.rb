class AddTmdbFieldsToScreenings < ActiveRecord::Migration[8.1]
  def change
    add_column :screenings, :tmdb_id, :integer
    add_column :screenings, :tmdb_poster_path, :string
  end
end
