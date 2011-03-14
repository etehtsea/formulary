require 'formula'

class Ffmpeg < Formula
  url 'http://ffmpeg.org/releases/ffmpeg-0.6.1.tar.bz2'
  homepage 'http://ffmpeg.org/'
  sha1 '24ada1d35fc000980090e773101e101ca45f85e5'

  head 'git://git.libav.org/libav.git'

  depends_on 'x264' => :optional
  depends_on 'faac' => :optional
  depends_on 'faad2' => :optional
  depends_on 'lame' => :optional
  depends_on 'theora' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'libogg' => :optional
  depends_on 'libvpx' => :optional
  depends_on 'xvid' => :optional

  def install
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-shared",
            "--enable-pthreads",
            "--enable-nonfree",
            "--enable-gpl",
            "--disable-indev=jack"]

    args << "--enable-libx264" if Formula.factory('x264').installed?
    args << "--enable-libfaac" if Formula.factory('faac').installed?
    args << "--enable-libmp3lame" if Formula.factory('lame').installed?
    args << "--enable-libtheora" if Formula.factory('theora').installed?
    args << "--enable-libvorbis" if Formula.factory('libvorbis').installed?
    args << "--enable-libvpx" if Formula.factory('libvpx').installed?
    args << "--enable-libxvid" if Formula.factory('xvid').installed?

    unless ARGV.build_head?
      args << "--enable-libfaad" if Formula.factory('faad2').installed?
    end

    # For 32-bit compilation under gcc 4.2, see:
    # http://trac.macports.org/ticket/20938#comment:22
    if MACOS_VERSION >= 10.6 and Hardware.is_32_bit?
      ENV.append_to_cflags "-mdynamic-no-pic"
    end

    system "./configure", *args

    if snow_leopard_64?
      inreplace 'config.mak' do |s|
        shflags = s.get_make_var 'SHFLAGS'
        s.change_make_var! 'SHFLAGS', shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
      end
    end

    system "make install"
  end
end
