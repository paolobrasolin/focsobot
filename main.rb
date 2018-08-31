require 'kimurai'

class GithubSpider < Kimurai::Base
  USER_AGENTS = ["Chrome", "Firefox", "Safari", "Opera"]

  @name = "matematicamente_spider"
  @engine = :mechanize
  @start_urls = [
    "https://www.matematicamente.it/forum/search.php?author_id=12354&sr=posts"
  ]
  @config = {
    user_agent: -> { USER_AGENTS.sample },
    browser: {
      before_request: {
        change_user_agent: true
      }
    }
  }

  def parse(response, url:, data: {})
    if response.at_xpath("//form[@id='jumpbox']")
      response.xpath("//ul[@class='searchresults']//a").each do |a|
        request_to :parse_thread_page, url: absolute_url(a[:href], base: url)
      end

      if next_page = response.at_xpath("//fieldset[@class='display-options']//a[@class='right-box right']")
        request_to :parse, url: absolute_url(next_page[:href], base: url)
      end
    else
      puts "Got kicked out. Retrying in 15s..."
      sleep 15
      request_to :parse, url: url
    end
  end

  def parse_thread_page(response, url:, data: {})
    if response.at_xpath("//form[@id='jumpbox']")
      id = url.split("%23").last
      content = response.at_xpath("//div[@id='#{id}']//div[@class='content']")
      date = response.at_xpath("//div[@id='#{id}']//p[@class='author']").text.split("»").last.strip
      save_to "killing_buddha.json", { html: content.to_s, date: date }, format: :pretty_json
    else
      puts "Got kicked out. Retrying in 15s..."
      sleep 15
      request_to :parse, url: url
    end
  end
end

GithubSpider.crawl!
