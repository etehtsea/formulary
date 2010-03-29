require 'formula'

class Mpd <Formula
  url 'http://downloads.sourceforge.net/project/musicpd/mpd/0.15.9/mpd-0.15.9.tar.bz2'
  homepage 'http://mpd.wikia.com'
  md5 '88f7bc0b17eac81d03b24929d12b8aa1'

  depends_on 'glib'
  depends_on 'libid3tag'
  depends_on 'pkg-config'
  depends_on 'flac'
  depends_on 'libshout'
  depends_on 'mad' => :optional
  depends_on 'faad2' => :optional
  depends_on 'fluid-synth'
  depends_on 'libcue' => :optional
  depends_on 'libmms' => :optional
  depends_on 'libzzip' => :optional

  def install
    # make faad.h findable (when brew is used elsewhere than /usr/local/)
    ENV.append 'CFLAGS', "-I#{HOMEBREW_PREFIX}/include"

    configure_args = [
      "--prefix=#{prefix}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--enable-bzip2",
      "--enable-flac",
      "--enable-shout",
      "--enable-fluidsynth",
      "--enable-zip",
    ]
    configure_args << "--disable-curl" if MACOS_VERSION <= 10.5

    system "./configure", *configure_args
    system "make install"
  end
end
