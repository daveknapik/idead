require "wikipedia"
require "treat"
include Treat::Core::DSL

class TrendingTopic
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
    nnp_trends = self.filter_by_tag(trending_topics, "NNP")

    dead = Array.new
    unknown = Array.new

    unless nnp_trends.empty?
      nnp_trends.each do |trend|
        page = Wikipedia.find trend

        if page.categories.present? && page.categories.select {|c| c =~ /deaths/}.present?
          dead << Person.new(name: page.title, status: "dead")
        else
          unknown << Person.new(name: page.title, status: "unknown")
        end
      end
    end

    return {dead: dead, unknown: unknown}
  end
end