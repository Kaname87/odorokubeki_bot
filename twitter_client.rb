# frozen_string_literal: true

require 'dotenv'
require 'twitter'
require './tweet_creator.rb'

class TwitterClient
  def initialize
    Dotenv.load
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['YOUR_CONSUMER_KEY']
      config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET']
      config.access_token        = ENV['YOUR_ACCESS_TOKEN']
      config.access_token_secret = ENV['YOUR_ACCESS_SECRET']
    end
  end

  def post(text)
    @client.update(text)
    p 'posted'
  rescue StandardError => e
    p e
  end
end
