require "wikipedia"
require "treat"
include Treat::Core::DSL

class TrendingTopic
  include ActiveModel::Model

  attr_accessor :name, :status, :wikipedia_url, :news_items

  def initialize(params)
    super(params)
    find_news_items
  end

  def find_news_items
    @news_items = GuardianContent::Content.search("\"#{self.name}\"", conditions: {from: (Date.today - 1).to_s, to: Date.today.to_s})
  end
  
  def self.filter_by_tag(trending_topics, tag="NNP")
    trending_topics.map do |trend|
      w = word(trend)
      w.apply :tag

      if w.tag == tag
        w.to_s
      end
    end.compact
  end

  def self.cross_reference_wikipedia(trending_topics)
    dead = Array.new
    unknown = Array.new

    unless trending_topics.empty?
      trending_topics.each do |trending_topic|
        wikipedia_page = Wikipedia.find(trending_topic.name, prop: ["info","categories"], inprop: "url")

        if wikipedia_page.categories.present? && wikipedia_page.categories.select {|c| c =~ /#{Time.now.year} deaths/}.present?
          trending_topic.status = "dead"
          trending_topic.wikipedia_url = wikipedia_page.page["fullurl"]
          dead << trending_topic
        elsif wikipedia_page.categories.present? # at least if categories are present, it means a Wikipedia page exists for trending_topic.name
          trending_topic.status = "unknown"
          trending_topic.wikipedia_url = wikipedia_page.page["fullurl"]
          unknown << trending_topic
        else
          trending_topic.status = "unknown"
          unknown << trending_topic
        end
      end
    end

    return {dead: dead, unknown: unknown}
  end
end