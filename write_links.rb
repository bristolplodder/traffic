require "rubygems"
require "json"
require 'open-uri'
require 'soda'
require 'nokogiri'
require 'csv'
require 'pp'

     client = SODA::Client.new({:domain => "XXXX", :username => "XXXX", :password => "XXXX", :app_token => "XXXX"})


doc =  Nokogiri::XML(open('XXXX',:http_basic_authentication => ['XXXX','XXXX']))


json = File.read('/var/www/rails_apps/traffic/input.json')
obj = JSON.parse(json)


@links = []

@link_loc = obj
       
       @link_loc.each do |ll|  
   
           @ll_id = "SECTIONTL"+ll[0].to_s
           @ll_lat = ll[2]
           @ll_long = ll[3]
           @ll_name = ll[4]

       @links << [@ll_id,@ll_name,@ll_lat,@ll_long]
     end

puts @links

    report = doc.xpath("//xmlns:elaboratedData")
     csv =[]
     @rows = []
     count = 0
  report.each do |item|
    location = item.xpath(".//xmlns:predefinedLocationReference")
    travel_time  = item.xpath(".//xmlns:travelTime")
    time = item.xpath(".//xmlns:time")
    if (time.text.to_i < 10000 && location.text[0..8] == "SectionTL")
     @links.each do |y|
#     puts "y: ",y[0][9..13].to_i,"location: ", location.text[9..13].to_i
      if (y[0][9..13].to_i ==  location.text[9..13].to_i)
          puts "y: ",y[0],"location: ", location.text[9..13].to_i
          @id = y[0]
          @name = y[1]
          @lat = y[2]
          @long = y[3]
         puts @name
          puts @lat
          puts @long 
       end
      end      
     

     @link_loc.each do |z|
       if (z[0].to_i == location.text.upcase[9..13].to_i)
         @speed = (z[1]/(travel_time.text.to_f/3600)).round(2) 
         @rows <<  [@id, @name, travel_time.text, time.text, @lat, @long,@speed,@location]
 
       end
     end




      @location = "("+@lat.to_s+"\xC2\xB0"+","+@long.to_s+"\xC2\xB0"+")"

    end
  end


 csv_str = @rows.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join("")


  update = []
 @rows.each do |x|

     update << {
    "section_id" => x[0],
    "section_description" => x[1],
    "travel_time" => x[2],
    "time" => x[3],
    "lat" => x[4],
    "long" => x[5],
    "est_speed" => x[6],
    "location" => {
    "longitude" => x[5],
    "latitude" => x[4]
    }
} 

end

puts update
    
  @response = client.put("XXXX-XXXX", update)
  @response = client.post("XXXX-XXXX", update)
