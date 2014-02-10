require 'spec_helper'
describe TrendingTopic do
  let(:trending_topics) { ["fantastic", "doctor", "David Tennant", "Matt Smith", "London", "time", "travel"] }
  
  describe ".filter_by_tag" do
    it "returns an array of TrendingTopic objects" do
      filtered_topics = TrendingTopic.filter_by_tag(trending_topics)
      filtered_topics.each do |ft|
        expect(ft).to be_a TrendingTopic
      end
    end

    context "no tag specified" do
      subject { TrendingTopic.filter_by_tag(trending_topics) }

      it "filters an array of strings by NNP" do
        expect(subject.map(&:name)).to include "David Tennant"
        expect(subject.map(&:name)).to include "Matt Smith"
        expect(subject.map(&:name)).to include "London"
      end
    end

    context "tag specified" do
      subject { TrendingTopic.filter_by_tag(trending_topics, "NN") }

      it "filters an array of strings by the specified tag" do
        expect(subject.map(&:name)).to include "doctor"
        expect(subject.map(&:name)).to include "time"
        expect(subject.map(&:name)).to include "travel"
      end
    end
  end

  describe ".cross_reference_wikipedia" do
    let(:wikipedia_page) { double(:page) }
    let(:categories)     { Array.new }
    let(:Wikipedia)      { double(:Wikipedia) }
    
    before do
      allow(Wikipedia).to receive(:find).and_return(wikipedia_page)
      allow(wikipedia_page).to receive(:categories).and_return(categories)
    end

    it "calls .filter_by_tag with trending_topics and 'NNP'" do
      expect(TrendingTopic).to receive(:filter_by_tag).with(trending_topics, "NNP").and_return(Array.new)
      TrendingTopic.cross_reference_wikipedia(trending_topics)
    end

    it "returns a hash with keys 'dead' and 'unknown', both of which hold arrays" do
      topics_cross_referenced = TrendingTopic.cross_reference_wikipedia(trending_topics)

      expect(topics_cross_referenced).to be_a Hash
      expect(topics_cross_referenced.keys).to include(:dead)
      expect(topics_cross_referenced.keys).to include(:unknown)
      expect(topics_cross_referenced[:dead]).to be_an Array
      expect(topics_cross_referenced[:unknown]).to be_an Array
    end

    context "no Wikipedia page found" do
      let(:categories)  { [] }

      it "classifies the topic as 'unknown'" do
        topics_cross_referenced = TrendingTopic.cross_reference_wikipedia(trending_topics)

        topics_cross_referenced[:unknown].each do |topic|
          expect(topic).to be_a TrendingTopic
          expect(topic.status).to eq "unknown"
        end
      end
    end

    context "death found this year" do
      let(:categories)  { ["Foo bar", "Categories:#{Time.now.year} deaths", "Bar foo"] }

      it "initializes the topic as a person with a status of 'dead' and puts them in dead array" do
        topics_cross_referenced = TrendingTopic.cross_reference_wikipedia(trending_topics)

        topics_cross_referenced[:dead].each do |topic|
          expect(topic).to be_a WikipediaResult::Person
          expect(topic.status).to eq "dead"
        end
      end
    end

    context "no deaths found" do
      let(:categories)  { ["Foo bar", "Bar foo"] }

      it "initializes the topic as a generic Wikipedia result with a status of 'unknown' and puts it in the unknown array" do
        topics_cross_referenced = TrendingTopic.cross_reference_wikipedia(trending_topics)

        expect(topics_cross_referenced[:dead]).to be_empty

        topics_cross_referenced[:unknown].each do |topic|
          expect(topic).to be_a WikipediaResult::Generic
          expect(topic.status).to eq "unknown"
        end
      end
    end
  end
end