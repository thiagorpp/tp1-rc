require 'open-uri'
require 'debugger'
require 'json'
require 'mongo'
require 'nokogiri'
require 'mechanize'
require 'restclient'
require 'rails'

include Mongo

client = Mongo::Client.new(
  [ '127.0.0.1:27017' ], :database => 'foursquare'
)

mechanize = Mechanize.new

agent = Mechanize.new do |agent|
    agent.user_agent_alias = 'Linux Firefox'
end

count = 0
client[:rc_venuesNY].find("tipsCount" => {"$gte" => 1, "$lt" => 5}).each do |v|
  unless v["complete"] == false
    count = count + 1
    if count > 10
      count = 0
      puts "Sleeping..."
      sleep(15)
    end

    name = v['name'].parameterize
    id = v['_id']
    url = "https://foursquare.com/v/#{name}/#{id}"

    puts url

    page = nil
    RestClient.get(url) do |response, request, result, &block|
      unless [404, 500].include? response.code
        page = agent.get(url)
      end
    end

    tipsID = []

    if page == nil
      next
    end

    if page.search('.tipPagination a').to_a.length > 0
      page.search('.tipPagination a').each do |link|

        RestClient.get('https://foursquare.com' + link['href']) do |response, request, result, &block|
          unless [404, 500].include? response.code
            'https://foursquare.com' + link['href']
            nextPage = agent.click(link)

            tip = {}
            tip['user'] = {}

            nextPage.search('#tipsList li').each do |tip|
              tipsID.push(tip['data-id'])
            end
          end
        end
      end
    else
      page.search('#tipsList li').each do |tip|
        tipsID.push(tip['data-id'])
      end
    end

    doc = {"tipsID" => tipsID, "complete" => false, "tipsCount" => tipsID.length}
    client[:rc_venuesNY].find("_id" => v["_id"]).find_one_and_update("$set" => doc)
  end
end
