require "uri"
require "net/http"
require "json"

class AvaApi
  def self.fetch_records(symbol)
    url =  url = URI("https://alpha-vantage.p.rapidapi.com/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&outputsize=compact&datatype=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = ENV["API_KEY"]
    # request["x-rapidapi-key"] = '2892a51f21mshd2e6029fa6ed0a2p1d83bajsnfe552f480759'
    request["x-rapidapi-host"] = "alpha-vantage.p.rapidapi.com"

    response = http.request(request)
    JSON.parse(response.body)
  end
end
