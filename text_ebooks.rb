#!/usr/bin/ruby
#based on https://gist.github.com/busterbenson/6695350, modified by @peteyreplies
 
# Make sure you have these gems installed
require 'rubygems'
require 'thread'
require 'twitter'
require 'marky_markov'
require 'date'
 
# Create a new Twitter account that you'd like to have your auto-tweets posted to
# Go to dev.twitter.com, create a new application with Read+Write permissions
# Create an access token + secret for the account and copy that and the consumer key and secrets here.
CONSUMER_KEY         = 'YOUR_KEY'
CONSUMER_SECRET      = 'YOUR_SECRET'
ACCESS_TOKEN         = 'YOUR_ACCESS_TOKEN'
ACCESS_TOKEN_SECRET  = 'YOUR_ACCESS_TOKEN_SECRET'
PATH_TO_TEXT         = 'YOUR_TEXT.csv'
ARCHIVED_TWEETS      = 'ARCHIVED_TWEETS.csv'
 
### -----------------------------------------------------------------------------------------------------
  
#auth to twitter
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = ACCESS_TOKEN
    config.access_token_secret = ACCESS_TOKEN_SECRET
  end

#randomly select lucidity on each run; 1 less lucid, 3 more 
n = rand(1..3)
markov = MarkyMarkov::TemporaryDictionary.new(n)
markov.parse_file PATH_TO_TEXT

#randomly select whether it generates 1 or 2 sentences (or just hardcode a number)
#m = rand(1..2)
tweet_text = markov.generate_n_sentences(1).split(/\#\</).first.chomp.chop

#make sure it's under 140
trunc_tweet = tweet_text[0..139]
  
#D20 that the tweet will be all caps because LOUD NOISES
d = rand(1..20)
if d == 20
	trunc_tweet = trunc_tweet.upcase
end 

#markov.save_dictionary!
markov.clear! # Clear the temporary dictionary because otherwise it's huge.

#printing tweet locally
 puts trunc_tweet

#append to archival csv w/ date and time 
date = Time.now.strftime("%m/%d/%Y")
time = Time.now.strftime('%H:%M"')
CSV.open(ARCHIVED_TWEETS, "a") do |csv|
  csv << [date, time, trunc_tweet]
  # ...
end

#post to twitter (comment out to debug locally)
 client.update(trunc_tweet)