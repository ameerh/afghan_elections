require 'uri'
require 'net/http'
require 'nokogiri'

task :get_districts_and_pc => :environment do
	# #Get Districts 
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

	# #Get Polling Centers 
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

	#Get Polling Stations
	uri = URI("http://www.iec.org.af/results/en/elections/presidentialpcajax_scanfile")
	polling_centers = PollingCenter.find(:all)
	polling_stations = Array.new
		polling_centers.each do |polling_center|
		response = Net::HTTP.post_form(uri, {"provinceId" => polling_center.Code[0,2].to_i, "pcId" => polling_center.Code})
		doc = Nokogiri::HTML(response.body)
		doc.css('.btn-primary').each do |button|
			value = button.attributes['onclick'].value
			url   = value.split("','")[0].split("('")[1]
			polling_station = Hash.new
			polling_station['PollingCenterId'] = polling_center.Code
			polling_station['image_url'] = url
			polling_stations << polling_station
		end
		if(polling_stations.count >= 50)
			result = PollingStation.create(polling_stations)
			polling_stations = Array.new
		end	
		puts polling_center.id
	end
	result = PollingStation.create(polling_stations)
end