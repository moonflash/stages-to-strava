require "nokogiri" 

originals = Dir.entries("original")
tcxs = Dir.entries("tcx")

read = originals - tcxs

@names = ["Time","Distance","Speed_Avg","Watts_Avg","HR_Avg","RPM_Avg","Speed_Max","Watts_Max","HR_Max","RPM_Max","KCal","KJ"]



def build_xml(start_time,final,data)
	builder = Nokogiri::XML::Builder.new do |xml|
	  xml.TrainingCenterDatabase("xsi:schemaLocation"=>"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd", "xmlns:ns5"=>"http://www.garmin.com/xmlschemas/ActivityGoals/v1" , "xmlns:ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2", "xmlns:ns2" => "http://www.garmin.com/xmlschemas/UserProfile/v2", "xmlns" => "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance") {
	    xml.Activities{
	    	xml.Activity("Sport" => 'Biking', "VismoxSport"=>"Indoor cycling") {
		      xml.Id start_time.strftime "%Y-%m-%dT%H:%M:%SZ"
		      xml.Lap('StartTime' => start_time){
		      	xml.TotalTimeSeconds time_in_seconds final["Time"]
		      	xml.DistanceMeters final["Distance"]
		      	xml.MaximumSpeed final["Speed_Max"]
		      	xml.Calories final["KCal"]
		      	xml.AverageHeartRateBpm {
		      		xml.Value final["HR_Avg"]
		      	} 
		      	xml.Intensity "Active"
		      	xml.TriggerMethod "Manual"
		      	for point in data
		      		#Time,Kilometers,KPH,Watts,HR,RPM
			      	xml.Track {
			      		xml.Trackpoint {
			      			xml.Cadence point[5].strip
			      			t = start_time + time_in_seconds(point[0])
			      			xml.Time t.strftime "%Y-%m-%dT%H:%M:%SZ"
			      			xml.Extensions {
			      				xml.TPX('xmlns'=>'http://www.garmin.com/xmlschemas/ActivityExtension/v2') {
			      					xml.Watts point[3]
			      					xml.Speed point[2].to_f * 0.277778
			      				}
			      			}
			      			xml.HeartRateBpm{
			      				xml.Value point[4]
			      			}
			      			xml.DistanceMeters point[1].to_f * 1000
			      		}
			      	}
			      end
		      }
		    }
	    }
	    
	  }
	end
	
end

def read_file(file_name)
	data = []
	final = {}
	puts "Enter Date of your ride 'dd/mm/yyyy'"
	date = gets.chomp
	puts "Enter Start time of your ride 'hh:mm'"
	time = gets.chomp
	date = date.split("/")
	time = time.split(":")
	begin
		start_time = Time.new(date[2], date[1], date[0], time[0], time[1])
	rescue
		puts "You entered the wrong date/time, your ride start will be set at the date-time of your file creation date."
		start_time = nil
	end

	start_time = File.ctime("original/"+file_name) unless start_time
	File.open("original/"+file_name).each do |line|
		if line[0].match(/\d/)
			data << line.split(",")
		else
			a = line.split(',')
			final[a[0]] = a[1].strip if @names.include? a.first
		end
	end
	xml = build_xml(start_time,final,data)
	tcx_file = "tcx/" + file_name.split(".")[0] + ".tcx"

	File.open(tcx_file, 'w') { |file| file.write(xml.to_xml) }
	puts "Your ride is ready at STAGES/tcx/#{tcx_file}"
end
def time_in_seconds(time)
	time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}
end

for file in read 
	read_file(file)
end
