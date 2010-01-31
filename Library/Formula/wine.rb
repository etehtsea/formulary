require 'formula'

class Wine <Formula
  url 'http://ibiblio.org/pub/linux/system/emulators/wine/wine-1.1.37.tar.bz2'
  md5 'a9144360723c8276dffdbcea9c1028d5'
  homepage 'http://www.winehq.org/'

  depends_on 'jpeg'
  depends_on 'mpg123' => :optional

  def install
    # Wine does not compile with LLVM yet
    ENV.gcc_4_2
    ENV.x11

    # Make sure we build 32bit version, because Wine64 is not fully functional yet
    build32 = "-arch i386 -m32"

    ENV["LIBS"] = "-lGL -lGLU"
    ENV.append "CFLAGS", build32
    ENV.append "CXXFLAGS", "-D_DARWIN_NO_64_BIT_INODE"
    ENV.append "LDFLAGS", [build32, "-framework CoreServices", "-lz", "-lGL -lGLU"].join(' ')
    ENV.append "DYLD_FALLBACK_LIBRARY_PATH", "/usr/X11/lib"

    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--disable-win16"
    system "make install"
    rename_binary
    install_wrapper
  end

  def caveats; <<-EOS
Get winetricks with:
    wget http://www.kegel.com/wine/winetricks > #{prefix}/bin/winetricks
    chmod +x #{prefix}/bin/winetricks
    brew link wine
    EOS
  end

  def wine_wrapper
    DATA
  end

  def rename_binary
    (bin+'wine').rename(bin+'wine.bin')
  end

  def install_wrapper
    (bin+'wine').write(wine_wrapper.read.gsub('@PREFIX@', prefix))
  end
end

__END__
#!/bin/sh
DYLD_FALLBACK_LIBRARY_PATH="/usr/X11/lib" \
"@PREFIX@/bin/wine.bin" "$@"
