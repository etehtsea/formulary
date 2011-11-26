require 'formula'

class Lame < Formula
  homepage 'http://lame.sourceforge.net/'
  url 'http://downloads.sourceforge.net/sourceforge/lame/lame-3.99.2.tar.gz'
  md5 'd049cc1c6b2be16805d5765cc0b23737'

  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}", "--enable-nasm"
    system "make install"
  end
end
