require "nokogiri"
require "date"
require_relative "../../../../lib/wordpress/comments/client"
require_relative "../../../support/match_date"

describe Wordpress::Comments::Client do

  let(:client) { Wordpress::Comments::Client.new 'http://mashable.com/feed' }
  let (:xml) { File.read(File.join('spec', 'fixtures', 'feed.xml')) }

  describe "#initialize" do

    it "stores a URL" do
      expect(client.url).to eq 'http://mashable.com/feed'
    end

  end

  describe "#parse" do

    let(:comments) { client.parse xml }
    let(:comment) { comments.first }

    it "extacts the link" do
      link = 'http://mashable.com/2015/01/27/amanda-peet-game-of-thrones/?utm_medium=feed&utm_source=rss'
      expect(comment[:link]).to eq link
    end

    it "extracts the title" do
      title = 'Amanda Peet thought \'Game of Thrones\' was a terrible idea'
      expect(comment[:title]).to eq title
    end

    it "extracts the name of the author" do
      expect(comment[:author]).to eq 'Neha Prakash'
    end

    it "extracts the date" do
      #Tue, 27 Jan 2015 18:55:39 +0000
      expect(comment[:date].year).to eq 2015
    end

    it "extracts the date (redux)" do
      #Tue, 27 Jan 2015 18:55:39 +0000
      expect(comment[:date]).to match_date "2015-01-27"
    end
  end

  describe "#fetch" do

    let (:comments) { client.fetch }

    context "success" do

      before(:each) do
        client.stub(:get).and_return xml #should_receive(:method) create a mock
      end

      it "build comment objects" do
        expect(comments.length).to eq 30
      end
    end

    context "Bad URL" do

      let(:client) { Wordpress::Comments::Client.new 'not a URL' }

      it "raise error" do
        expect{
          client.fetch
        }.to raise_error(Errno::ENOENT)
      end

    end

    context "bad XML" do

      before(:each) do
        client.stub(:get).and_return 'Bad XML' #should_receive(:method) create a mock
      end

      it "raise error from Nokogiri" do
        expect{
          client.fetch
        }.to raise_error(Nokogiri::XML::SyntaxError)
      end
    end

  end
end