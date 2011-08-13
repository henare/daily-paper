require 'mechanize'

def get_item(url)
  agent = Mechanize.new
  page = agent.get(url)
  i = {}

  content = page.at('div.article')
  i['headline'] = content.at('h1').inner_text.strip
  i['byline'] = content.at('div.byline').children.last.inner_text.strip
  i['article_url'] = url
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

  i['section'] = "World"
  i['thumbnail'] = ""
  i
end

def render_article(item)
  thumnail = item['thumbnail'] ? "<img class=\"thumbnail\" alt=\"Thumbnail\" src=\"#{item['thumbnail']}\" />" : ""

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
      #{item['thumbnail']}
      #{item['article_content']}
    </div>
    <div class="footer">
      <p class="original"><span>Original: </span><a href="#{item['article_url']}">#{item['article_url']}</a></p>
    </div>
  </div>
  EOF
end

["http://www.abc.net.au/news/2011-08-13/sarah-palin-presidential-speculation-heats-up/2837704?section=world", "http://www.abc.net.au/news/2011-08-13/deadly-crackdown-after-friday-prayers-in-syria/2837682?section=world"].each do |url|
  puts render_article(get_item(url))
end