require 'spec_helper'
describe TrendingTopic do
  let(:trends) { ["fantastic", "doctor", "David Tennant", "Matt Smith", "London", "time", "travel"] }
  
  describe ".filter_by_tag" do
    it "returns an array of strings" do
      filtered_trends = TrendingTopic.filter_by_tag(trends)
      filtered_trends.each do |ft|
        expect(ft).to be_a String
      end
    end

    context "no tag specified" do
      subject { TrendingTopic.filter_by_tag(trends) }

      it "filters an array of strings by NNP" do
        expect(subject).to eq ["David Tennant", "Matt Smith", "London"]
      end
    end

    context "tag specified" do
      subject { TrendingTopic.filter_by_tag(trends, "NN") }

      it "filters an array of strings by the specified tag" do
        expect(subject).to eq ["doctor", "time", "travel"]
      end
    end
  end

  describe ".cross_reference_wikipedia" do
    let(:wikipedia_page)  { double(:page) }
    let(:categories)      { Array.new }
    let(:Wikipedia)       { double(:Wikipedia) }
    let(:filtered_trends) { TrendingTopic.filter_by_tag(trends, "NNP") }
    let(:trending_topics) { filtered_trends.map {|trend| TrendingTopic.new(name: trend)} }
    
    before do
      allow(Wikipedia).to receive(:find).and_return(wikipedia_page)
      allow(wikipedia_page).to receive(:categories).and_return(categories)
      TrendingTopic.any_instance.stub(:find_news_items)
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
          expect(topic.status).to eq "unknown"
        end
      end
    end

    context "death found this year" do
      let(:categories)  { ["Foo bar", "Categories:#{Time.now.year} deaths", "Bar foo"] }

      it "initializes the topic as a person with a status of 'dead' and puts them in dead array" do
        topics_cross_referenced = TrendingTopic.cross_reference_wikipedia(trending_topics)

        topics_cross_referenced[:dead].each do |topic|
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
          expect(topic.status).to eq "unknown"
        end
      end
    end
  end

  describe "#find_news_items" do
    it "should search for news items by quoted topic name from yesterday through today" do
      topic_name = "Tom Baker"
      GuardianContent::Content.stub(:search).and_return([GuardianContent::Content.new])
      expect(GuardianContent::Content).to receive(:search).with("\"#{topic_name}\"", {conditions: {from: (Date.today - 1).to_s, to: Date.today.to_s}})
      TrendingTopic.new(name: topic_name)
    end
  end
end