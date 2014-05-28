#petey_ebooks

##about
These are two Ruby scripts I use to run Twitter _ebooks style bots. They are both based off [Buster Benson's code](https://gist.github.com/busterbenson/6695350), but more or less heavily modified to do other things his code didn't. 

##twitter_ebooks
This script will scrape the last 3200 tweets from a user, clean them and uses MarkyMarkov to generate sentences, which will be pseudorandomly more or less lucid each time it runs. You should use it if you have a Twitter account (yours or someone else's) that you want to make an _ebooks version of. I use it to power [@grokbot_](http://twitter.com/grokbot_). 

Warning: this scrapes twitter each time you run it, and if you do so too aggressively, Twitter might get angry. If you're debugging locally, you might want to scrape once and then use the corpus to tweak the settings. 

##text_ebooks
This script takes a .txt file of your choose and uses the same library and basic methods to generate sentences as per above. You should use it if you have a text file (of a book, of a collection of blog posts, etc) that you want to represent through in an _ebooks style. I use it to power [@mitblogs_ebooks](http://twitter.com/mitblogs_ebooks).

##need to fix
	* The sentence generator is a bit wonky. It doesn't always end a tweet with appropriate punctuation, and it sometimes awkwardly truncates mid-sentence. 