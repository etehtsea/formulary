require 'formula'

class Aqbanking < Formula
  url 'http://www2.aquamaniac.de/sites/download/download.php?package=03&release=93&file=01&dummy=aqbanking-5.0.23.tar.gz'
  homepage 'http://www.aqbanking.de/'
  md5 '5b108357764aea38da4572581b07400c'
  head 'http://devel.aqbanking.de/svn/aqbanking/trunk'

  depends_on 'gettext'
  depends_on 'gmp'
  depends_on 'gwenhywfar'
  depends_on 'ktoblzcheck' => :optional

  def install
    ENV.j1
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cli",
                          "--with-gwen-dir=#{HOMEBREW_PREFIX}"
    system "make install"
  end
end
