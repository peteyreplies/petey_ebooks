#!/usr/bin/ruby
#based on https://gist.github.com/busterbenson/6695350, modified by @peteyreplies
 
# Make sure you have these gems installed
require 'rubygems'
require 'thread'
require 'csv'
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
PATH_TO_TWEETS_CSV   = 'SCRAPED_TWEETS.csv'
PATH_TO_TWEETS_CLEAN = 'CLEANED_TWEETS.txt'
ARCHIVED_TWEETS      = 'ARCHIVED_TWEETS.csv'
SOURCE_ACCOUNT       = 'PLACEHOLDER' #note no @ sign! 
 
### -----------------------------------------------------------------------------------------------------
  
#auth to twitter
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = ACCESS_TOKEN
    config.access_token_secret = ACCESS_TOKEN_SECRET
  end

#download all of a users tweets, modified from http://git.io/AKtAYA
def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {:count => 200, :include_rts => true, :include_entities => false}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

scrapedtweets = client.get_all_tweets(SOURCE_ACCOUNT)

#read that array of tweets into a csv 
scrapedtweets.each do |twt|
	CSV.open(PATH_TO_TWEETS_CSV, "a") do |csv|
		csv << [twt.text]
	end
end

#load csv in 
csv_text = CSV.parse(File.read(PATH_TO_TWEETS_CSV))
 
# Create a new clean file of text that acts as the seed for your Markov chains
File.open(PATH_TO_TWEETS_CLEAN, 'w') do |file|
  csv_text.reverse.each do |row|
    # Strip links, new lines, and mentions. more: http://goo.gl/hlJLue
    tweet_text = row[0].gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub(/\n/,' ').gsub(/\B[@]\S+\b/, '')
    # Save the text
    file.write("#{tweet_text}\n")
  end
end

#randomly select lucidity on each run; 1 less lucid, 3 more 
n = rand(1..3)
markov = MarkyMarkov::TemporaryDictionary.new(n)
markov.parse_file PATH_TO_TWEETS_CLEAN

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

#delete working files
File.delete(PATH_TO_TWEETS_CSV)
File.delete(PATH_TO_TWEETS_CLEAN)

#post to twitter (comment out to debug locally)
 client.update(tweet_text)