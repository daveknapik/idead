class TwitterClient
  def initialize
    @client = client
  end

  def trends(woeid=1)
    # get trending topics as an array of topics
    trends = @client.trends(woeid).map(&:name)

    # strip off the hash tags
    trends = trends.map {|t| strip_hash_tags(t) }

    # insert spaces before capital letters, unless it already has whitespace
    trends = trends.map {|t| t.match(/\s/) ? t : break_up_one_word_tags(t)}
  end

  private
  
  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["IDEAD_TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["IDEAD_TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["IDEAD_TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["IDEAD_TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def strip_hash_tags(string)
    string.gsub(/#/,'')
  end

  def break_up_one_word_tags(string)
    string.gsub(/(?=[A-Z])/,' \1').strip
  end
end