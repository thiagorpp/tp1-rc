require 'open-uri'
require 'debugger'
require 'json'

CLIENT_NAME = ''

# New York
LATITUDE = '40.7142700'
LONGITUDE = '-74.005970'

RADIUS = '200'
MAXROWS = 80000

fileName = 'cities/newyork.txt'

file = File.open(fileName, 'w')

url = 'http://api.geonames.org/findNearbyJSON'\
      '?lat=%s'\
      '&lng=%s'\
      '&username=%s'\
      '&radius=%s'\
      '&style=SHORT'\
      '&featureClass=L'\
      '&maxRows=%s' % [LATITUDE, LONGITUDE, CLIENT_NAME, RADIUS, MAXROWS]

puts "loading...\n"

puts url
content = open(url).read
json_data = JSON.parse(content)

puts "Load complete!\n"
puts json_data['geonames'].length

d = 0
count = 0
json_data['geonames'].each do |place|
  dist = place['distance'].to_i

  if dist > d and count <= 20
    d = dist
    count = 0

    puts dist
  end

  if dist == d
    lat = place['lat'].to_f
    lng = place['lng'].to_f

    file.write("#{lat},#{lng}\n")

    count = count + 1

    if count >= 20
      d = d + 1
      count = 0
    end
  end
end

file.close unless file == nil
