require 'erb'
require 'mechanize'

agent = Mechanize.new

url = "http://www.abc.net.au/news/2011-08-13/sarah-palin-presidential-speculation-heats-up/2837704?section=world"

page = agent.get(url)
item = {}
content = page.at('div.article')
item['headline'] = content.at('h1').inner_text.strip
item['byline'] = content.at('div.byline').children.last.inner_text.strip
item['article_url'] = url
item['article_content'] = ""
item['lead'] = ""

content.search('p').each_with_index do |v,k|
  if v.attributes['class']
    next
  elsif k == 1
    item['lead'] = v.inner_text
  else
    item['article_content'] += v.to_s
  end
end

item['section'] = "World"
item['thumbnail'] = ""

def render_article
  template = ERB.new <<-EOF
  <div class="section-news">
    <div class="meta">
      <p class="publication">The&nbsp;ABC</p>
      <p class="section"><%= item['section'] %></p>
    </div>
    <div class="headline">
    <h2><%= item['headline'] %></h2
    </div>
    <div class="intro">
      <p class="byline"><%= item['byline'] %></p>
      <p class="standfirst"><%= item['lead'] %></p>
    </div>
    <div class="body">
    <% if !item['thumbnail'].empty? %>
        <img class="thumbnail" alt="Thumbnail" src="<%= item['thumbnail'] %>" />
      <% end %>
      <%= item['article_content'] %>
    </div>
    <div class="footer">
      <p class="original"><span>Original: </span><a href="<%= item['article_url'] %>"><%= item['article_url'] %></a></p>
    </div>
  </div>
  EOF
  template.result
end

puts render_article