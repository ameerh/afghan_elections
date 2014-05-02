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

	#Get Polling Stations Method 1
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

	# Get Polling Stations Method 2
	image_pre_uri = "http://results.iec.org.af/pdf/PreliminaryResultImages/"
	polling_centers = PollingCenter.find(:all, :limit => 2)
	polling_stations = Array.new
	polling_centers.each do |polling_center|
		flag = false
		i = 1
		PollingCenterId = polling_center.PollingCentreId
		DistrictId = polling_center.district_id
		ProvinceId = District.find(:first, :conditions => ["DistrictId=?",polling_center.district_id]).province_id
		base_img_url = image_pre_uri.to_s + ProvinceId.to_s + "/" + DistrictId.to_s + "/" + PollingCenterId.to_s + "/" 
		base_name    = ProvinceId.to_s + "_" + DistrictId.to_s + "_" + PollingCenterId.to_s + "_"
		while(!flag) do
			if(i<9)
				image = "0" + i.to_s + ".jpeg"
				name  = base_name.to_s + "0" + i.to_s + ".jpeg"
			else	
				image = i.to_s + ".jpeg"
				name  = base_name.to_s + i.to_s + ".jpeg"
			end	
			img_url = base_img_url.to_s + image.to_s 
			if(remote_file_exists?(img_url))
				open("public/images/"+name, 'wb') do |file|
					puts img_url
					file << open(img_url).read
				end
				binding.pry
			else
				flag = true
				binding.pry
			end
			i += 1
		end
	end
end

def remote_file_exists?(url)
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
end