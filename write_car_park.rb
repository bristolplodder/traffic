require "rubygems"
require "json"
require 'open-uri'
require 'soda'
require 'nokogiri'
require 'csv'
require 'pp'

client = SODA::Client.new({:domain => "XXXX", :username => "XXXX", :password => "XXXX", :app_token => "XXXX"})

public_publish_list = ['BRIS-C00001','BRIS-C00011','BRIS-C00012','BRIS-C91221']


doc =  Nokogiri::XML(open('XXXX',:http_basic_authentication => ['XXXX','XXXX']))


@public_rows =[]
public_publish_list.each do |pb|
  @code = pb
  location = doc.xpath("//xmlns:parkingFacilityTable")
  location.each do |loc|
    loc_detail = loc.xpath(".//xmlns:parkingArea")
    if ( loc_detail.attribute('id').to_s == pb)
      desc = loc_detail.xpath(".//xmlns:parkingAreaName")
      @desc_val = desc.xpath(".//xmlns:value").text
      @cap = loc_detail.xpath(".//xmlns:totalParkingCapacity").text
    end
  end
  report = doc.xpath("//xmlns:parkingAreaStatus")
  report.each do |item|
    ref = item.xpath(".//xmlns:parkingAreaReference")
    if (ref.attribute('id').to_s == pb)  
      @status_time = item.xpath(".//xmlns:parkingFacilityStatusTime").text
      @occupancy = item.xpath(".//xmlns:parkingFacilityOccupancy").text 
      @assigned = item.xpath(".//xmlns:numberOfVacantAssignedParkingSpaces").text
    end
  end
    @cap_f = @cap.to_f
    @occupancy_f = @occupancy.to_f
    @assigned_f = @assigned.to_f
    @remain = @assigned.to_i
    @occupancy = (100*(@occupancy_f/@cap_f)).to_i


      @public_rows << [@code, @desc_val, @cap, @occupancy, @remain, @status_time]
end

@public_update = []
@public_rows.each do |x|

     @public_update << {
    "cp_code" => x[0],
    "description" => x[1],
    "capacity" => x[2],
    "occupancy_pc" => x[3],
    "remaining_spaces" => x[4],
    "status_time" => x[5]
} 

end

puts @public_update
    
  @response = client.put("a427-ptgs", @public_update)
