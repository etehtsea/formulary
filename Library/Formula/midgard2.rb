require 'formula'

class Midgard2 < Formula
  url 'http://www.midgard-project.org/midcom-serveattachmentguid-b459b3e443f711e0a6353dc3bca0241a241a/midgard2-core-10.05.4.tar.gz'
  head 'https://github.com/midgardproject/midgard-core.git', :branch => 'ratatoskr'
  homepage 'http://www.midgard-project.org/'
  md5 '99dcf5d5e39901712a882598e3da17d2'

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'dbus-glib'
  depends_on 'libgda'

  if ARGV.build_head? and MacOS.xcode_version >= "4.3"
    # remove the autoreconf if possible, no comment provided about why it is there
    # so we have no basis to make a decision at this point.
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    if ARGV.build_head?
      system "autoreconf", "-i", "--force"
      system "automake"
    end
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libgda4",
                          "--with-dbus-support",
                          "--enable-introspection=no"
    system "make install"
  end
end
