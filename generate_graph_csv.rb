require 'json'
require 'mongo'
require 'debugger'
require 'csv'
include Mongo

tipsCount2 = 30

client = Mongo::Client.new(
  [ '127.0.0.1:27017' ], :database => 'foursquare'
)

venues = client[:rc_venuesNY].find(
					"tipsCount2" => {
						"$gte" => tipsCount2
					})

nodes = []
edges = {}
users = {}

failUser = 0
totalUser = 0

puts "Aggregating data..."
venues.each do |v|
	nodes.push({'id' => v['_id'], 'name' => v['name']})

	v['tips'].each do |t|
		if t['user'] and t['user'].has_key? 'id'
			users[t['user']['id']] = [] unless users.has_key? t['user']['id']
			users[t['user']['id']].push(v['_id'])

		else
			failUser = failUser + 1
		end

		totalUser = totalUser + 1

		# puts "#{failUser} / #{totalUser}"
	end
end

puts "creating edges..."
users.each do |user, places|
	newV = places.uniq.sort

	newV.each do |p1|
		newV.each do |p2|
			if p2 > p1
				edges[p2]     = {} unless edges.has_key? p2
				edges[p2][p1] = 0  unless edges[p2].has_key? p1
				edges[p2][p1] = edges[p2][p1] + 1
			end
		end
	end
end

puts "writing edges..."

CSV.open("../data/edges#{tipsCount2}.csv", "w") do |csv|
	edges.each do |k1, v1|
		edges[k1].each do |k2, v2|
			csv << [k1, k2, v2]
		end
	end
end

puts "writing nodes..."

CSV.open("../data/nodes#{tipsCount2}.csv", "w") do |csv|
  nodes.each do |node|
    csv << [node["id"], node["name"]]
  end
end

puts "#{failUser} / #{totalUser}"
