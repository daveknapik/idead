require 'twitter_client'

class DeathsController < ApplicationController
  def index
    twitter = TwitterClient.new
    trends = twitter.trends

    topics_cross_referenced_against_wikipedia = Rails.cache.fetch("topics_cross_referenced_against_wikipedia", expires_in: 1.minute) do
      TrendingTopic.cross_reference_wikipedia(trends)
    end

    @dead = topics_cross_referenced_against_wikipedia[:dead]
    @unknown = topics_cross_referenced_against_wikipedia[:unknown]
  end
end
