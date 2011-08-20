require 'rubygems'
require 'mechanize'

class ABCNews
  def get_item(url, section)
    agent = Mechanize.new
    page = agent.get(url)
    i = {}

    content = page.at('div.article')

    i['section'] = section
    i['article_url'] = url
    i['headline'] = content.at('h1').inner_text.strip
    i['byline'] = content.at('div.byline').children.last.inner_text.strip if content.at('div.byline')
    i['thumbnail'] = content.at('div.photo.left').at('img').attribute('src').value if content.at('div.photo.left')
    i['article_content'] = ""
    i['lead'] = ""

    content.search('p').each_with_index do |v,k|
      if v.attributes['class']
        next
      elsif k == 1
        i['lead'] = v.inner_text
      else
        i['article_content'] += v.to_s
      end
    end
    i['words'] = i['article_content'].split.size
    i
  end

  def render_article(item)
    thumbnail = item['thumbnail'] ? "<img class=\"thumbnail\" alt=\"Thumbnail\" src=\"#{item['thumbnail']}\" />" : ""

    template = <<-EOF
    <div class="section-news">
      <div class="meta">
        <p class="publication">The&nbsp;ABC</p>
        <p class="section">#{item['section']}</p>
      </div>
      <div class="headline">
      <h2>#{item['headline']}</h2>
      </div>
      <div class="intro">
        <p class="byline">#{item['byline']}</p>
        <p class="standfirst">#{item['lead']}</p>
      </div>
      <div class="body">
        #{thumbnail}
        #{item['article_content']}
      </div>
      <div class="footer">
        <p class="original"><span>Original: </span><a href="#{item['article_url']}">#{item['article_url']}</a></p>
      </div>
    </div>
    EOF
  end

  def get_headlines(url)
    agent = Mechanize.new

    base_url = "http://www.abc.net.au"

    page = agent.get(url)

    stories = []
    ["div.lead", "div.tall"].each do |e|
      stories << base_url + page.at(e).at("a").attribute("href").value if page.at(e)
    end

    page.at("ul.headlines").search("a").each do |a|
      next if a.at('em') # Don't get video stories
      stories << base_url + a.attribute("href").value
    end
    stories
  end
end
