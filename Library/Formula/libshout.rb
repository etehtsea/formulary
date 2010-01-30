require 'formula'

class Libshout <Formula
  url 'http://downloads.us.xiph.org/releases/libshout/libshout-2.2.2.tar.gz'
  homepage 'http://www.icecast.org/'
  md5 '4f75fc9901c724b712c371c9a1e782d3'

  depends_on 'theora' => :optional
  depends_on 'speex'  => :optional

  depends_on 'pkg-config'
  depends_on 'libogg'
  depends_on 'libvorbis'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
