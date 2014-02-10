require "wikipedia"
require "treat"
include Treat::Core::DSL

class TrendingTopic
  include ActiveModel::Model

  attr_accessor :name, :status

  def self.filter_by_tag(trending_topics, tag="NNP")
    trending_topics.map do |trend|
      w = word(trend)
      w.apply :tag

      if w.tag == tag
        self.new(name: w.to_s)
      end
    end.compact
  end

  def self.cross_reference_wikipedia(trending_topics)
    nnp_trends = self.filter_by_tag(trending_topics, "NNP")

    dead = Array.new
    unknown = Array.new

    unless nnp_trends.empty?
      nnp_trends.each do |trend|
        wikipedia_page = Wikipedia.find trend.name

        if wikipedia_page.categories.present? && wikipedia_page.categories.select {|c| c =~ /#{Time.now.year} deaths/}.present?
          dead << WikipediaResult::Person.new(name: wikipedia_page.title, status: "dead")
        elsif wikipedia_page.categories.present? # at least if categories are present, it means a Wikipedia page exists for trend.name
          unknown << WikipediaResult::Generic.new(name: wikipedia_page.title, status: "unknown")
        else
          trend.status = "unknown"
          unknown << trend
        end
      end
    end

    return {dead: dead, unknown: unknown}
  end
end