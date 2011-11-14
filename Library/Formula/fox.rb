require 'formula'

class Fox < Formula
  # Development and stable branches are incompatible
  if ARGV.include? '--devel'
    url 'http://ftp.fox-toolkit.org/pub/fox-1.7.30.tar.gz'
    md5 '345df53f1e652bc99d1348444b4e3016'
  else
    url 'ftp://ftp.fox-toolkit.org/pub/fox-1.6.44.tar.gz'
    md5 '6ccc8cbcfa6e4c8b6e4deeeb39c36434'
  end
  homepage 'http://www.fox-toolkit.org/'

  fails_with_llvm "Inline asm errors during build" if ARGV.include? '--devel'

  def install
    ENV.x11

    # Yep, won't find freetype unless this is all set.
    ENV.append "CFLAGS", "-I/usr/X11/include/freetype2"
    ENV.append "CPPFLAGS", "-I/usr/X11/include/freetype2"
    ENV.append "CXXFLAGS", "-I/usr/X11/include/freetype2"

    system "./configure", "--enable-release",
                          "--prefix=#{prefix}",
                          "--with-x", "--with-opengl"
    system "make install"
  end
end
