# frozen_string_literal: true

require_relative 'twitter_client.rb'
require_relative 'tweet_creator.rb'

# このファイルをSchedulerで実行
if $PROGRAM_NAME == __FILE__
  tweet = TweetCreator.new(KEYWORD_ARTICLES_CSV_NAME).pick_random_one
  TwitterClient.new.post(tweet)
end
