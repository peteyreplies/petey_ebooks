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

#randomly select whether it generates 1 or 2 sentences, and generate them until you come in under 140
under140 = false

begin
  m = rand(1..2)
  tweet_text = markov.generate_n_sentences(m).split(/\#\</).first.chomp.chop
  if tweet_text.length <= 140 then
  	under140 = true 
  end
end until under140 == true
  
#D20 that the tweet will be all caps because LOUD NOISES
d = rand(1..20)
if d == 20
	tweet_text = tweet_text.upcase
end 

#markov.save_dictionary!
markov.clear! # Clear the temporary dictionary because otherwise it's huge.

#printing tweet locally
 puts tweet_text

#append to archival csv w/ date and time 
date = Time.now.strftime("%m/%d/%Y")
time = Time.now.strftime('%H:%M"')
CSV.open(ARCHIVED_TWEETS, "a") do |csv|
  csv << [date, time, tweet_text]
  # ...
end

#post to twitter (comment out to debug locally)
 client.update(tweet_text)