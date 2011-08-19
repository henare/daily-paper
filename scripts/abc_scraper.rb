require 'abc_news'
require 'json'

abc = ABCNews.new

file_directory = "#{File.dirname(__FILE__)}/../public/archive/#{Time.now.strftime('%Y-%m-%d')}"
Dir.mkdir file_directory unless File.directory? file_directory

# sections = [
#     {:links => [], :meta => {:url => "http://www.abc.net.au/news/nsw/", :title => "NSW"}},
#     {:links => [], :meta => {:url => "http://www.abc.net.au/news/world/", :title => "World"}},
#     {:links => [], :meta => {:url => "http://www.abc.net.au/news/business/", :title => "Business"}}
# ]
sections = [
  {:links => [], :meta => {:url => "http://www.abc.net.au/news/nsw/", :title => "NSW"}},
  {:links => [], :meta => {:url => "http://www.abc.net.au/news/world/", :title => "World"}}
]

sections.each do |s|
  abc.get_headlines(s[:meta][:url]).each do |h|
    item = abc.get_item(h, s[:meta][:title])
    file = File.open("#{file_directory}/#{item['article_url'].split('/')[-2]}.html", 'w')
    file.write(abc.render_article(item))
    file.close
    link = {
      :path => "#{item['article_url'].split('/')[-2]}",
      :file => "#{item['article_url'].split('/')[-2]}.html",
      :words => item['words'],
      :id => item['article_url'].split('/')[-2],
      :title => item['headline']
    }
    s[:links] << link
  end
end

contents = {
  :meta => {:max_words => 1234, :paper_name => "ABC News"},
  :sections => sections
}

file = File.open("#{file_directory}/contents.json", 'w')
file.write(contents.to_json)
file.close
