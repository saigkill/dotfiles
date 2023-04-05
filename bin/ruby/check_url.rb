#!/usr/bin/env ruby
# encoding: UTF-8
# (c) 2016 Sascha Manns <Sascha.Manns@outlook.de>
# This script was born after a Ubuntu Upgrade. I wanted to know when the repositories are available for my Ubuntu version.

require "net/http"

url0 = "http://ppa.launchpad.net/diesch/testing/ubuntu/dists/yakkety"
url1 = "http://ppa.launchpad.net/i2p.packages/i2p/ubuntu/dists/yakkety"
url2 = "http://ppa.launchpad.net/kubuntu-ppa/backports/ubuntu/dists/yakkety"
url3 = "http://ppa.launchpad.net/kubuntu-ppa/ppa/ubuntu/dists/yakkety"
url4 = "http://ppa.launchpad.net/kubuntu-ppa/beta/ubuntu/dists/yakkety"
url5 = "http://ppa.launchpad.net/jonathonf/pepperflashplugin-nonfree/ubuntu/dists/yakkety"
url6 = "http://ppa.launchpad.net/retroshare/unstable/ubuntu/dists/yakkety"
url7 = "http://ppa.launchpad.net/shutter/ppa/ubuntu/dists/yakkety"
url8 = "http://ppa.launchpad.net/webupd8team/y-ppa-manager/ubuntu/dists/yakkety"
url9 = "http://ppa.launchpad.net/plasmazilla/ubuntu/dists/yakkety"
#http://ppa.launchpad.net/plasmazilla/releases/ubuntu

[url0,url1,url2,url3,url4,url5,url7,url8,url9].each do |i|

  begin
    url = URI.parse(i)
  rescue URI::InvalidURIError => err
    p err
    exit
  end

  if url.host && url.port
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    p res.code + " on: #{i}"
  else
    p "Error parsing url: #{i}"
  end
end
