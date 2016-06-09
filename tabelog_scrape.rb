# -*= coding: utf-8 -*=
require 'anemone'
require 'nokogiri'
require 'kconv'

urls = []

31.times do |area|
  area_str = (area + 1301).to_s
  url_area = "http://tabelog.com/tokyo/A" + area_str + "/rstLst/RC/"
  10.times do |i|
    url = url_area + (i + 1).to_s + "/?SrtT=rt"
    urls.push(url)
  end
end

yokohama = "http://tabelog.com/kanagawa/A1401/rstLst/RC/"
kamakura = "http://tabelog.com/kanagawa/A1404/rstLst/RC/"
10.times do |i|
  url = yokohama + (i + 1).to_s + "/?SrtT=rt"
  urls.push(url)
  url = kamakura + (i + 1).to_s + "/?SrtT=rt"
  urls.push(url)
end

opts = {
  obey_robots_txt: true,
  depth_limit: 0
}

Anemone.crawl(urls, opts) do |anemone|
  anemone.on_every_page do |page|
    doc = Nokogiri::HTML.parse(page.body.toutf8)

    sub_category = doc.xpath("//*[@data-id='area2']/div/p/span").text

    items = doc.xpath("//li[contains(@class,\"rstlst-group bkmk-rst clearfix\")]/div[1]")
    items.each{ |item|
      show = item.xpath("div[1]/div[1]/div[1]/strong//a/@href")
      rank = item.xpath("div[1]/div[1]/span[1]").text
      name = item.xpath("div[1]/div[1]/div[1]/strong/a").text
      genre = item.xpath("div[1]/div[1]/div[1]/span").text
      star = item.xpath("div[3]/div[1]/p[1]/em").text
      dinner = item.xpath("div[3]/div[2]/p[1]/span").text + item.xpath("div[3]/div[2]/p[1]/em").text
      lunch = item.xpath("div[3]/div[2]/p[2]/span").text + item.xpath("div[3]/div[2]/p[2]/em").text
      
      Anemone.crawl(show, opts) do |a|
        a.on_every_page do |p|
          d = Nokogiri::HTML.parse(p.body.toutf8)
          pv = d.xpath("//div[@class='access']/p/a").text
          tel = d.xpath("//strong[@property='v:tel']").text
          address1 = d.xpath("//tr[@class='address']/td/p/span[1]").text
          address2 = d.xpath("//tr[@class='address']/td/p/span[2]").text
          address3 = d.xpath("//tr[@class='address']/td/p/span[3]").text
        
          if pv.gsub(/[^0-9]/,"").to_i >= 3000 and star.to_f >= 3.8
            puts sub_category.to_s. + "," + 
                 rank.to_s + "," + 
                 name.to_s + "," + 
                 genre.to_s + "," + 
                 tel.to_s + "," + 
                 address1.to_s + address2.to_s + address3.to_s + "," + 
                 show.to_s + "," + 
                 star.to_s + "," + 
                 pv.to_s.gsub(/[^0-9]/,"") + ","+
                 dinner.to_s.gsub(",","") + "," + 
                 lunch.to_s.gsub(",","") 
          end
        end
      end
    }
  end
end

