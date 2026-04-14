class AddMoreSocialsToSiteSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :site_settings, :facebook_url, :string
    add_column :site_settings, :youtube_url, :string
  end
end
