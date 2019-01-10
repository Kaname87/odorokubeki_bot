# frozen_string_literal: true

require 'twitter'

require './keys'
require './tweet_creator.rb'

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = YOUR_CONSUMER_KEY
      config.consumer_secret     = YOUR_CONSUMER_SECRET
      config.access_token        = YOUR_ACCESS_TOKEN
      config.access_token_secret = YOUR_ACCESS_SECRET
    end
  end

  def post(text)
    @client.update(text)
  rescue StandardError => e
    p e
  end
  p "posted"
end
