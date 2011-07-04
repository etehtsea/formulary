require 'formula'

class Lftp < Formula
  url 'http://ftp.yars.free.net/pub/source/lftp/lftp-4.3.1.tar.bz2'
  homepage 'http://lftp.yar.ru/'
  md5 'ea45acfb47b5590d4675c50dc0c6e13c'

  depends_on 'pkg-config' => :build
  depends_on 'readline'
  depends_on 'gnutls'

  def install
    # Bus error
    ENV.no_optimization if MacOS.leopard?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
