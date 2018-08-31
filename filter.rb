require 'json'
require 'nokogiri'

INPUT_FILE = "killing_buddha.json"
OUTPUT_FILE = "killing_buddha.txt"

data = JSON.parse(File.read(INPUT_FILE))

data.map! { |post| post["html"] }

data.map! do |html|
  fragment = Nokogiri::HTML::fragment(html)
  fragment.search('.//blockquote').remove
  fragment.search('.//a').remove
  fragment.text
end

File.write(OUTPUT_FILE, data.join)
