require 'formula'

class Highlight < Formula
  url 'http://www.andre-simon.de/zip/highlight-3.5.tar.bz2'
  homepage 'http://www.andre-simon.de/doku/highlight/en/highlight.html'
  sha1 '0e57b45103b6f471a96f987f98dc5e09fed138b5'

  depends_on 'boost'
  depends_on 'lua'

  def install
    system "make", "PREFIX=#{prefix}", "conf_dir=#{etc}/highlight"
    system "make", "PREFIX=#{prefix}", "conf_dir=#{etc}/highlight", "install"
  end
end
