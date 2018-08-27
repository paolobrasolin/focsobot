# github_spider.rb
require 'kimurai'

USER_ID = 12354

class GithubSpider < Kimurai::Base
  @name = "matematicamente_spider"
  @engine = :mechanize
  @start_urls = [
    "https://www.matematicamente.it/forum/search.php?author_id=#{USER_ID}&sr=posts"
  ]
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    browser: {
      before_request: { delay: 6..8 }
    }
  }

  def parse(response, url:, data: {})
    response.xpath("//ul[@class='searchresults']//a").each do |a|
      request_to :parse_thread_page, url: absolute_url(a[:href], base: url)
    end

    if next_page = response.at_xpath("//fieldset[@class='display-options']//a[@class='right-box right']")
      request_to :parse, url: absolute_url(next_page[:href], base: url)
    end
  end

  def parse_thread_page(response, url:, data: {})
    id = url.split("%23").last
    content = response.at_xpath("//div[@id='#{id}']//div[@class='content']")
    date = response.at_xpath("//div[@id='#{id}']//p[@class='author']").
                  text.split("»").last.strip
    save_to "results.json", { html: content.to_s, date: date }, format: :pretty_json
  end
end

GithubSpider.crawl!
