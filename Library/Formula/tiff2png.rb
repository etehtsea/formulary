require 'formula'

class Tiff2png < Formula
  url 'ftp://ftp.simplesystems.org/pub/libpng/png/applications/tiff2png-0.91.tar.gz'
  homepage 'http://www.libpng.org/pub/png/apps/tiff2png.html'
  md5 'b5db7add863c5cf469197aa327c0b202'

  depends_on 'libtiff'
  depends_on 'jpeg'

  def install
    inreplace 'Makefile.unx' do |s|
      s.remove_make_var! 'DEBUGFLAGS'
      s.change_make_var! 'CC', ENV.cc
      s.change_make_var! 'LIBTIFF', HOMEBREW_PREFIX+"lib"
      s.change_make_var! 'TIFFINC', HOMEBREW_PREFIX+"include"
      s.change_make_var! 'LIBJPEG', HOMEBREW_PREFIX+"lib"
      s.change_make_var! 'LIBPNG', '/usr/X11/lib'
      s.change_make_var! 'PNGINC', '/usr/X11/include'
      s.change_make_var! 'ZLIB', '/usr/lib'
    end

    system 'make -f Makefile.unx'
    bin.install 'tiff2png'
  end
end
