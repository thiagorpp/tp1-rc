require 'open-uri'
require 'debugger'
require 'json'
require 'mongo'

include Mongo

client = Mongo::Client.new(
  [ '127.0.0.1:27017' ], :database => 'foursquare'
)

# coll = db.collection("venues")

# Set the foursquare API key
CLIENT_ID = ''
CLIENT_SECRET = ''

# https://developer.foursquare.com/docs/venues/search
# Type of search
INTENT = 'browse'

# Api version date
VERSION = 20140806

# Location coordinates
LOCATION = ''

# Radius in meters for the search
RADIUS = 2000

# Results are limited to 50
LIMIT = 500

# Food =D
CATEGORY = '4d4b7105d754a06374d81259'

CATEGORIES = ['503288ae91d4c4b30a586d67,4bf58dd8d48988d1c8941735,4bf58dd8d48988d14e941735,4bf58dd8d48988d152941735,4bf58dd8d48988d107941735',
              '4bf58dd8d48988d142941735,4bf58dd8d48988d169941735,52e81612bcbc57f1066b7a01,4bf58dd8d48988d1df931735,4bf58dd8d48988d179941735',
              '4bf58dd8d48988d16a941735,52e81612bcbc57f1066b7a02,52e81612bcbc57f1066b79f1,4bf58dd8d48988d16b941735,4bf58dd8d48988d143941735',
              '52e81612bcbc57f1066b7a0c,52e81612bcbc57f1066b79f4,4bf58dd8d48988d16c941735,4bf58dd8d48988d153941735,4bf58dd8d48988d128941735',
              '4bf58dd8d48988d16d941735,4bf58dd8d48988d17a941735,52e81612bcbc57f1066b7a03,4bf58dd8d48988d144941735,5293a7d53cf9994f4e043a45',
              '4bf58dd8d48988d145941735,4bf58dd8d48988d1e0931735,52e81612bcbc57f1066b7a00,52e81612bcbc57f1066b79f2,4bf58dd8d48988d154941735',
              '4bf58dd8d48988d1bc941735,52f2ae52bcbc57f1066b8b81,4bf58dd8d48988d146941735,4bf58dd8d48988d1d0941735,4bf58dd8d48988d1f5931735',
              '4bf58dd8d48988d147941735,4e0e22f5a56208c4ea9a85a0,4bf58dd8d48988d148941735,4bf58dd8d48988d108941735,4bf58dd8d48988d109941735',
              '52e81612bcbc57f1066b7a05,4bf58dd8d48988d10a941735,4bf58dd8d48988d10b941735,4bf58dd8d48988d16e941735,4eb1bd1c3b7b55596b4a748f',
              '4edd64a0c7ddd24ca188df1a,52e81612bcbc57f1066b7a09,4bf58dd8d48988d1cb941735,4bf58dd8d48988d10c941735,4d4ae6fc7a7b7dea34424761',
              '4bf58dd8d48988d155941735,4bf58dd8d48988d10d941735,4c2cd86ed066bed06c3c5209,4bf58dd8d48988d10e941735,52e81612bcbc57f1066b79ff',
              '52e81612bcbc57f1066b79fe,52e81612bcbc57f1066b79fb,4bf58dd8d48988d16f941735,52af0bd33cf9994f4e043bdd,52e81612bcbc57f1066b79fa',
              '4bf58dd8d48988d1c9941735,4bf58dd8d48988d10f941735,4deefc054765f83613cdba6f,52e81612bcbc57f1066b7a06,4bf58dd8d48988d110941735',
              '4bf58dd8d48988d111941735,52e81612bcbc57f1066b79fd,4bf58dd8d48988d112941735,4bf58dd8d48988d113941735,52e81612bcbc57f1066b79fc',
              '4bf58dd8d48988d1be941735,4bf58dd8d48988d1bf941735,4bf58dd8d48988d156941735,4bf58dd8d48988d1c0941735,4bf58dd8d48988d1c1941735',
              '4bf58dd8d48988d115941735,52e81612bcbc57f1066b79f9,4bf58dd8d48988d1c2941735,4eb1d5724b900d56c88a45fe,4bf58dd8d48988d1c3941735',
              '4bf58dd8d48988d157941735,52e81612bcbc57f1066b79f8,52e81612bcbc57f1066b79f7,4eb1bfa43b7b52c0e1adc2e8,52e81612bcbc57f1066b7a0a',
              '4bf58dd8d48988d1ca941735,52e81612bcbc57f1066b7a04,4def73e84765ae376e57713a,4bf58dd8d48988d1d1941735,4bf58dd8d48988d1c4941735',
              '52960bac3cf9994f4e043ac4,4bf58dd8d48988d1bd941735,4bf58dd8d48988d1c5941735,4bf58dd8d48988d1c6941735,4bf58dd8d48988d1ce941735',
              '4bf58dd8d48988d1c7941735,4bf58dd8d48988d1dd931735,4bf58dd8d48988d1cd941735,4bf58dd8d48988d14f941735,52e81612bcbc57f1066b79f3',
              '4bf58dd8d48988d150941735,5413605de4b0ae91d18581a9,4bf58dd8d48988d1cc941735,4bf58dd8d48988d1d2941735,4bf58dd8d48988d158941735',
              '4bf58dd8d48988d151941735,4bf58dd8d48988d1db931735,4bf58dd8d48988d1dc931735,4bf58dd8d48988d149941735,52af39fb3cf9994f4e043be9',
              '4f04af1f2fb6e1c99f3db0bb,4bf58dd8d48988d1d3941735,4bf58dd8d48988d14a941735,4bf58dd8d48988d14b941735,4bf58dd8d48988d14c941735,512e7cae91d4cbb4e5efe0af']

fileName = 'cities/newyork.txt'

def insertVenue(client, venue)
  venue[:_id] = venue.delete('id')

  if client[:venues_chicago].find(:_id => venue[:_id]).count() == 0
    client[:venues_chicago].insert_one(venue)
  end
end

def saveLog(client, line)
  doc = {}
  doc['line'] = line

  if client[:log_venues_chicago].find().count() == 0
    client[:log_venues_chicago].insert_one(doc)
  else
    client[:log_venues_chicago].find().find_one_and_update('$set' => doc)
  end
end

def getLogLine(client)
  if client[:log_venues_chicago].find().count() > 0
    return client[:log_venues_chicago].find().first['line']
  else
    return 0
  end
end

logLine = getLogLine(client)

File.readlines(fileName).each_with_index do |line, index|
  if logLine > index
    next
  end

  puts "BEGIN ON LINE #{index}\n\n\n"

  saveLog(client, index)
  location = line.strip

  url = 'https://api.foursquare.com/v2/venues/search'\
        '?client_id=%s'\
        '&client_secret=%s'\
        '&ll=%s'\
        '&radius=%s'\
        '&v=%s'\
        '&categoryId=%s'\
        '&limit=%s'

  urlDefault = url % [CLIENT_ID, CLIENT_SECRET, location, RADIUS,
                 VERSION, CATEGORY, LIMIT]

  puts urlDefault
  content = open(urlDefault).read
  json_data = JSON.parse(content)

  if json_data['response']['venues'].length >= 50
    n = 0
    CATEGORIES.each do |categorie|
      puts "Execucao #{n}"
      n = n + 1

      urlTmp = url % [CLIENT_ID, CLIENT_SECRET, location, RADIUS,
                     VERSION, categorie, LIMIT]

      json_data = JSON.parse(open(urlTmp).read)

      if json_data['response']['venues'].length >= 50
        puts "(2) Inserting venues quantity >= 50. Requesting again..."
        categorie.split(',').each do |cat|
          urlTmp = url % [CLIENT_ID, CLIENT_SECRET, location, RADIUS,
                         VERSION, cat, LIMIT]

          json_data = JSON.parse(open(urlTmp).read)

          if json_data['meta']['code'] == 200
            json_data['response']['venues'].each do |venue|
              insertVenue(client, venue)
            end
          end
        end
      else
        puts "(2) Inserting venues quantity < 50"
        json_data['response']['venues'].each do |venue|
          insertVenue(client, venue)
        end
      end
    end

  else
    puts "(1) Inserting venues quantity < 50"
    json_data['response']['venues'].each do |venue|
      insertVenue(client, venue)
    end
  end
end
