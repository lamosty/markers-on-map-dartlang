class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.string :title
      t.decimal :lat, :precision => 10, :scale => 6
      t.decimal :lng, :precision => 10, :scale => 6
      t.string :street
      t.integer :zip
      t.string :city

      t.timestamps
    end
  end
end
