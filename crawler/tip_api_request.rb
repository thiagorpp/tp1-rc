require 'open-uri'
require 'json'
require 'mongo'

include Mongo

client = Mongo::Client.new(
  [ '127.0.0.1:27017' ], :database => 'foursquare'
)

# https://developer.foursquare.com/docs/tips/tips
TIP_ID = ''

VERSION = 20140806

credentials = [
	{
		'id' => '',
		'secret' => ''
	}
]

credentials = credentials.shuffle

venues = client[:rc_venuesNY].find("complete" => false,
					"tipsCount" => {
						"$gte" => 1, "$lt" => 5
					}).to_a

cPos = 0
venues.each do |v|
	tips = []

	total = v['tipsID'].length
	v['tipsID'].each do |id|
		url = 'https://api.foursquare.com/v2/tips/%s'\
	        '?client_id=%s'\
	        '&client_secret=%s'\
	        '&v=%s'

		ok = false
		loop do
			urlDefault = url % [id, credentials[cPos]['id'], credentials[cPos]['secret'], VERSION]
			puts urlDefault
			begin
				content = open(urlDefault, 'User-Agent' => 'ruby').read
				json_data = JSON.parse(content)

				if json_data['meta']['code'] == 200
					ok = true
					tips.push(json_data['response']['tip'])
				end

				if ((tips.length/total.to_f)*100).to_i % 10 == 0
					puts ((tips.length/total.to_f)*100).to_i
				end
			rescue OpenURI::HTTPError => e
				response = e.io

				puts response.status
				puts response.string

				if [400, 404].include? response.status[0].to_i
					ok = true
				end
				if response.status[0].to_i == 403
					cPos = (cPos + 1)%credentials.length
					puts "#{cPos} of #{credentials.length}"
				end
			rescue Errno::ECONNRESET => e
				puts e
			end

			break if ok
		end
	end

	doc = {"tips" => tips, "complete" => true, "tipsCount2" => tips.length}
	client[:rc_venuesNY].find("_id" => v["_id"]).find_one_and_update("$set" => doc)
end
