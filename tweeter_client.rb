require 'twitter'

require './keys'
require './tweet_creator.rb'

class TweeterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = YOUR_CONSUMER_KEY
      config.consumer_secret     = YOUR_CONSUMER_SECRET
      config.access_token        = YOUR_ACCESS_TOKEN
      config.access_token_secret = YOUR_ACCESS_SECRET
    end
  end

  def post(text) 
      begin
        @client.update(text)
      rescue => e
        p e
      end
  end
end

# random_tweetを実行する
if __FILE__ == $0
    tweet = pickone()
    TweeterClient.new.post(tweet)
end