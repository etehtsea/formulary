require 'formula'

class Ftgl <Formula
  url 'http://downloads.sourceforge.net/project/ftgl/FTGL%20Source/2.1.3~rc5/ftgl-2.1.3-rc5.tar.gz'
  homepage 'http://sourceforge.net/projects/ftgl/'
  md5 'fcf4d0567b7de9875d4e99a9f7423633'

  depends_on 'pkg-config'

  def install
    if Formula.factory("doxygen").installed?
      puts "If doxygen is installed, the docs may still fail to build."
      puts "Try \"brew unlink doxygen\" before installing ftgl, and then"
      puts "use \"brew link doxygen\" afterwards to reactivate it."
    end

    # Freetype - include headers, libs and put freetype-config in path
    ENV.prepend 'PATH', "/usr/X11/bin", ":"
    ENV.x11

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-freetypetest",
    # Skip building the example program by failing to find GLUT (MacPorts)
                          "--with-glut-inc=/dev/null",
                          "--with-glut-lib=/dev/null"

    # Hack the package info
    inreplace "ftgl.pc", "Requires.private: freetype2\n", ""

    system "make install"
  end
end
