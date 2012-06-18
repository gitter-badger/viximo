require 'rubygems'
require "net/https"
require 'pp'
require "uri"
require 'digest/hmac'
require 'json'

class Viximo
  def initialize(api_key, api_secret)
    @key = api_key
    @secret = api_secret
    @uri = "https://api.socialzone.viximo.com"
  end
  
  #params is a hash with request parameters we want to send and their values
  def send_message(params)
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    parameters = ""
    params.each do |k,v|
      if parameters.empty?
        parameters = "#{k}=#{v}"
      else
        parameters += "&#{k}=#{v}"
      end
    end
    sig = generate_signature(params)
    parameters += "&signature=#{sig}"

    puts parameters

    response = http.post("/api/2/apps/#{@key}/users/127/messages.json", "#{parameters}")
    pp response.body
    return response.body
  end

  def broadcast(params)
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    parameters = ""
    params.each do |k,v|
      if parameters.empty?
        parameters = "#{k}=#{v}"
      else
        parameters += "&#{k}=#{v}"
      end
    end
    parameters += "&signature=#{generate_signature(params)}"

    puts parameters
    response = http.post("/api/2/apps/#{@key}/broadcast_notifications.json", "#{parameters}")
    pp response
    pp response.body
    return response.body
  end

  def generate_signature(params)
    value_string = ""
    params.keys.sort.each do |key|
      value_string += params[key].to_s
    end
    signature = Digest::HMAC.new(@secret,Digest::SHA256).hexdigest(value_string)
    return signature
  end
end