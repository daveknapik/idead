require 'twitter_client'

class DeathsController < ApplicationController
  def index
    twitter = TwitterClient.new

    topics_cross_referenced = Rails.cache.fetch("topics_cross_referenced", expires_in: 1.minute) do
      trends = TrendingTopic.filter_by_tag(twitter.trends, "NNP")
      trending_topics = trends.map { |trend| TrendingTopic.new(name: trend) }
      TrendingTopic.cross_reference_wikipedia(trending_topics)
    end

    @dead = topics_cross_referenced[:dead]
    @unknown = topics_cross_referenced[:unknown]
  end
end
