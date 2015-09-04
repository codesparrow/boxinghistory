class RenameImageUrlInProducts < ActiveRecord::Migration
  def change
    rename_column :products, :image_url, :preview
  end
end
