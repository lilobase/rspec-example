require "nokogiri"
require "date"
require "open-uri"

module Wordpress
  module Comments
    class Client
      def initialize url
        @url = url
      end

      attr_reader :url

      def parse xml
        doc = Nokogiri::XML(xml) { |config| config.strict}
        doc.search('item').map do |doc_item|
          item = {}
          item[:link] = doc_item.at('link').text
          item[:title] = doc_item.at('title').text
          item[:author] = doc_item.xpath('dc:creator').text
          item[:date] = DateTime.parse(doc_item.at('pubDate').text)
          item
        end
      end

      def fetch
        xml = get @url
        parse xml
      end

      private

      def get url
        open url
      end
    end
  end
end