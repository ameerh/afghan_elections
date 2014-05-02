require 'uri'
require 'net/http'
require 'nokogiri'
require 'timeout'

task :get_districts_and_pc => :environment do
	#Get Districts 
	uri = URI("http://www.iec.org.af/results/en/elections/getdistrict")
	provinces = Province.find(:all)
	provinces.each do |province|
		response = Net::HTTP.post_form(uri, {"provinceId" => province.id})
		districts = JSON.parse(response.body)
		districts.each do |district|
			district['province_id'] = province.id
		end	
		result = District.create(districts)
	end

	#Get Polling Centers 
	uri = URI("http://www.iec.org.af/results/en/elections/getPC")
	districts = District.find(:all)
	districts.each do |district|
		response = Net::HTTP.post_form(uri, {"districtId" => district.DistrictId})
		polling_centers = JSON.parse(response.body)
		polling_centers.each do |polling_center|
			polling_center['district_id'] = district.DistrictId
		end	
		result = PollingCenter.create(polling_centers)
	end
end