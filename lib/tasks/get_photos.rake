require 'uri'
require 'net/http'
require 'nokogiri'
require 'timeout'

task :get_districts_and_pc => :environment do
	# Get Photos
	image_pre_uri = "http://results.iec.org.af/pdf/PreliminaryResultImages/"
	polling_centers = PollingCenter.find(:all)
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