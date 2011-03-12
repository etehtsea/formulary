require 'formula'

class Ushare < Formula
  url 'http://ushare.geexbox.org/releases/ushare-1.1a.tar.bz2'
  homepage 'http://ushare.geexbox.org/'
  md5 '5bbcdbf1ff85a9710fa3d4e82ccaa251'

  depends_on 'gettext'
  depends_on 'libupnp'
  depends_on 'libdlna'

  def patches
    { :p0 =>
      "http://svn.macports.org/repository/macports/trunk/dports/net/ushare/files/patch-configure.diff"
    }
  end

  def install
    # Need to explicitly add gettext here.
    ENV.append 'LDFLAGS', "-lintl"

    inreplace 'configure', /config.h/, 'src/config.h'
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--enable-dlna",
                          "--with-libupnp-dir=#{HOMEBREW_PREFIX}",
                          "--with-libdlna-dir=#{HOMEBREW_PREFIX}",
                          "--disable-strip"
    system "make install"
    man1.install "src/ushare.1"
  end
end
