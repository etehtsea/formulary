require 'formula'

def glib?; ARGV.include? '--with-glib'; end
def qt?; ARGV.include? '--with-qt4'; end

class PopplerData < Formula
  url 'http://poppler.freedesktop.org/poppler-data-0.4.4.tar.gz'
  md5 'f3a1afa9218386b50ffd262c00b35b31'
end

class Poppler < Formula
  url 'http://poppler.freedesktop.org/poppler-0.16.7.tar.gz'
  homepage 'http://poppler.freedesktop.org/'
  md5 '3afa28e3c8c4f06b0fbca3c91e06394e'

  depends_on 'pkg-config' => :build
  depends_on 'qt' if qt?
  depends_on 'glib' if glib?
  depends_on 'cairo' if glib? # Needs a newer Cairo build than OS X 10.6.7 provides

  def options
    [
      ["--with-qt4", "Build Qt backend"],
      ["--with-glib", "Build Glib backend"],
      ["--enable-xpdf-headers", "Also install XPDF headers"]
    ]
  end

  def install
    ENV.x11 # For Fontconfig headers

    if qt?
      ENV['POPPLER_QT4_CFLAGS'] = `#{HOMEBREW_PREFIX}/bin/pkg-config QtCore QtGui --libs`.chomp
      ENV.append 'LDFLAGS', "-Wl,-F#{HOMEBREW_PREFIX}/lib"
    end

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    # Explicitly disable Qt if not requested because `POPPLER_QT4_CFLAGS` won't
    # be set and the build will fail.
    args << ( qt? ? '--enable-poppler-qt4' : '--disable-poppler-qt4' )
    args << '--enable-poppler-glib' if glib?
    args << "--enable-xpdf-headers" if ARGV.include? "--enable-xpdf-headers"

    system "./configure", *args
    system "make install"

    # Install poppler font data.
    PopplerData.new.brew do
      system "make install prefix=#{prefix}"
    end
  end
end
