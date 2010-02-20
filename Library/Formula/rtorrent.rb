require 'formula'

class Rtorrent <Formula
  url 'http://libtorrent.rakshasa.no/downloads/rtorrent-0.8.6.tar.gz'
  homepage 'http://libtorrent.rakshasa.no/'
  md5 'b804c45c01c40312926bcea6b55bb084'

  depends_on 'pkg-config'
  depends_on 'libsigc++'
  depends_on 'libtorrent'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make"
    system "make install"
  end
end
