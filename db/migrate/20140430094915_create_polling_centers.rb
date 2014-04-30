class CreatePollingCenters < ActiveRecord::Migration
  def change
    create_table :polling_centers do |t|
      t.text :DariName
      t.string :Code
      t.integer :PollingCentreId
      t.integer :district_id

      t.timestamps
    end
  end
end
