class AddCityAndCountryToMarker < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :title
    end

    create_table :countries do |t|
      t.string :title
    end

    create_table :markers do |t|
      t.string :heading
      t.string :body
      t.string :markerType

      t.decimal :lat, :precision => 10, :scale => 6
      t.decimal :lng, :precision => 10, :scale => 6
      t.string :street
      t.string :zip
      t.belongs_to :city
      t.belongs_to :country

      t.timestamps
    end
  end
end
