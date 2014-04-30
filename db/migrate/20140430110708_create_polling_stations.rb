class CreatePollingStations < ActiveRecord::Migration
  def change
    create_table :polling_stations do |t|
      t.string :PollingCenterId
      t.string :image_url

      t.timestamps
    end
  end
end
