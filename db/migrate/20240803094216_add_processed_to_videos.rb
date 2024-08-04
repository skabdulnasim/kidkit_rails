class AddProcessedToVideos < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :processed, :boolean, default: false, null: false
  end
end
