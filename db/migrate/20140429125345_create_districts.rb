class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :EnglishName
      t.text :DariName
      t.integer :DistrictId
      t.integer :province_id

      t.timestamps
    end
  end
end
