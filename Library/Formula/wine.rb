require 'formula'

class WineGecko < Formula
  url 'http://downloads.sourceforge.net/wine/wine_gecko-1.4-x86.msi', :using => :nounzip
  sha1 'c30aa99621e98336eb4b7e2074118b8af8ea2ad5'

  devel do
    url 'http://downloads.sourceforge.net/wine/wine_gecko-1.5-x86.msi', :using => :nounzip
    sha1 '07b2bc74d03c885bb39124a7641715314cd3ae71'
  end
end

class Wine < Formula
  homepage 'http://winehq.org/'
  url 'http://downloads.sourceforge.net/project/wine/Source/wine-1.4.tar.bz2'
  sha256 '99a437bb8bd350bb1499d59183635e58217e73d631379c43cfd0d6020428ee65'
  head 'git://source.winehq.org/git/wine.git'

  devel do
    url 'http://downloads.sourceforge.net/project/wine/Source/wine-1.5.0.tar.bz2'
    sha256 'ad15143d2f8b38e2b5b8569b46efd09f9d13ce558dad431e17c471ca1412742b'
  end

  depends_on 'jpeg'
  depends_on 'libicns'

  fails_with :llvm do
    build 2336
    cause 'llvm-gcc does not respect force_align_arg_pointer'
  end

  # the following libraries are currently not specified as dependencies, or not built as 32-bit:
  # configure: libsane, libv4l, libgphoto2, liblcms, gstreamer-0.10, libcapi20, libgsm, libtiff

  # Wine loads many libraries lazily using dlopen calls, so it needs these paths
  # to be searched by dyld.
  # Including /usr/lib because wine, as of 1.3.15, tries to dlopen
  # libncurses.5.4.dylib, and fails to find it without the fallback path.

  def wine_wrapper; <<-EOS.undent
    #!/bin/sh
    DYLD_FALLBACK_LIBRARY_PATH="/usr/X11/lib:#{HOMEBREW_PREFIX}/lib:/usr/lib" "#{bin}/wine.bin" "$@"
    EOS
  end

  def install
    ENV.x11

    # Build 32-bit; Wine doesn't support 64-bit host builds on OS X.
    build32 = "-arch i386 -m32"

    ENV["LIBS"] = "-lGL -lGLU"
    ENV.append "CFLAGS", build32
    if ENV.compiler == :clang
      opoo <<-EOS.undent
        Clang currently miscompiles some parts of Wine. If you have gcc, you
        can get a more stable build with:
          brew install wine --use-gcc
      EOS
    end
    ENV.append "CXXFLAGS", "-D_DARWIN_NO_64_BIT_INODE"
    ENV.append "LDFLAGS", "#{build32} -framework CoreServices -lz -lGL -lGLU"

    args = ["--prefix=#{prefix}",
            "--x-include=/usr/X11/include/",
            "--x-lib=/usr/X11/lib/",
            "--with-x",
            "--with-coreaudio",
            "--with-opengl"]
    args << "--disable-win16" if MacOS.leopard? or ENV.compiler == :clang

    # 64-bit builds of mpg123 are incompatible with 32-bit builds of Wine
    args << "--without-mpg123" if Hardware.is_64_bit?

    system "./configure", *args
    system "make install"

    # Don't need Gnome desktop support
    rm_rf share+'applications'

    # Download Gecko once so we don't need to redownload for each prefix
    gecko = WineGecko.new
    gecko.brew { (share+'wine/gecko').install Dir["*"] }

    # Use a wrapper script, so rename wine to wine.bin
    # and name our startup script wine
    mv (bin+'wine'), (bin+'wine.bin')
    (bin+'wine').write(wine_wrapper)
  end

  def patches
    p = []
    # Wine tests CFI support by calling clang, but then attempts to use as, which
    # does not work. Use clang for assembling too.
    p << 'https://raw.github.com/gist/1755988/266f883f568c223ab25da08581c1a08c47bb770f/winebuild.patch' if ENV.compiler == :clang
    p
  end

  def caveats
    s = <<-EOS.undent
      For best results, you will want to install the latest version of XQuartz:
        http://xquartz.macosforge.org/

      You may also want to get winetricks:
        brew install winetricks

      Or check out:
        http://code.google.com/p/osxwinebuilder/
    EOS
    return s
  end
end
