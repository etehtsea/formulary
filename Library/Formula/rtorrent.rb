require 'formula'

class Rtorrent < Formula
  url 'http://libtorrent.rakshasa.no/downloads/rtorrent-0.8.6.tar.gz'
  homepage 'http://libtorrent.rakshasa.no/'
  md5 'b804c45c01c40312926bcea6b55bb084'

  depends_on 'pkg-config' => :build
  depends_on 'libsigc++'
  depends_on 'libtorrent'
  depends_on 'xmlrpc-c' => :optional

  def install
    args = ["--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"]
    args << "--with-xmlrpc-c" if Formula.factory("xmlrpc-c").installed?
    if MACOS_VERSION == 10.5
      inreplace 'configure' do |s|
        s.gsub! '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" 2>/dev/null`', '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" | sed -e "s/-arch [^-]*/-arch $(uname -m) /" 2>/dev/null`'
      end
    end
    system "./configure", *args
    system "make"
    system "make install"
  end
end
