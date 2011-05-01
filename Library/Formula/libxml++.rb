require 'formula'

class Libxmlxx < Formula
  url 'http://ftp.gnome.org/pub/GNOME/sources/libxml++/2.34/libxml++-2.34.1.tar.gz'
  homepage 'http://libxmlplusplus.sourceforge.net'
  md5 'c73e3916a1a0f4d01291c852e9af6241'

  depends_on 'glibmm'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
