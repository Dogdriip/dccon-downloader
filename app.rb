require 'rubygems'
require 'nokogiri'
require 'capybara-webkit'
require 'capybara/dsl'
require 'open-uri'
require 'net/http'

request_uri = "http://dccon.dcinside.com/##{ARGV.shift}"

include Capybara::DSL
Capybara.current_driver = :webkit
Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.allow_url("*dcinside*")
end
visit request_uri
doc = Nokogiri::HTML.parse body
if doc
  innerdiv = doc.css "div.wrap_dccone > div.content > div#pop_wrap > div#package_detail > div.inner"
  srcstring = innerdiv.css "div:nth-of-type(1) > div.icon_view > div.mandoo_info_box > strong:nth-of-type(1) > span.name"
  dcconpkg_title = srcstring.text.tr " ", "_"
  Dir.mkdir dcconpkg_title, 755 unless Dir.exist? dcconpkg_title
  puts "Downloading. This may take a while..."
  innerdiv.css("ul.Img_box > li").each do |dccon|
    imgobj = dccon.css "img"
    dccon_url = imgobj.attr('src').text
    dccon_title = imgobj.attr('alt').text
    File.write("#{dcconpkg_title}/#{dccon_title}.png", open("http:#{dccon_url}", "Referer" => request_uri).read, {mode: 'wb'})
  end
  puts "Download completed!"
else
  puts "ERR: Server closed or structure modified!"
end
