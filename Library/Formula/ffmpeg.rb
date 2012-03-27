require 'formula'

def ffplay?
  ARGV.include? '--with-ffplay'
end

class Ffmpeg < Formula
  url 'http://ffmpeg.org/releases/ffmpeg-0.10.2.tar.bz2'
  homepage 'http://ffmpeg.org/'
  sha1 '743f44a71f93b14c9b26ca2424b0da8457cef4be'

  head 'git://git.videolan.org/ffmpeg.git'

  fails_with_llvm 'Undefined symbols when linking libavfilter'

  def options
    [
      ["--with-tools", "Install additional FFmpeg tools."],
      ["--with-ffplay", "Build ffplay."]
    ]
  end

  depends_on 'yasm' => :build
  depends_on 'x264' => :optional
  depends_on 'faac' => :optional
  depends_on 'lame' => :optional
  depends_on 'rtmpdump' => :optional
  depends_on 'theora' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'libogg' => :optional
  depends_on 'libvpx' => :optional
  depends_on 'xvid' => :optional
  depends_on 'opencore-amr' => :optional
  depends_on 'libass' => :optional

  depends_on 'sdl' if ffplay?

  def install
    ENV.x11
    args = ["--prefix=#{prefix}",
            "--enable-shared",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            "--enable-hardcoded-tables",
            "--enable-libfreetype",
            "--cc=#{ENV.cc}"]

    args << "--enable-libx264" if Formula.factory('x264').installed?
    args << "--enable-libfaac" if Formula.factory('faac').installed?
    args << "--enable-libmp3lame" if Formula.factory('lame').installed?
    args << "--enable-librtmp" if Formula.factory('rtmpdump').installed?
    args << "--enable-libtheora" if Formula.factory('theora').installed?
    args << "--enable-libvorbis" if Formula.factory('libvorbis').installed?
    args << "--enable-libvpx" if Formula.factory('libvpx').installed?
    args << "--enable-libxvid" if Formula.factory('xvid').installed?
    args << "--enable-libopencore-amrnb" if Formula.factory('opencore-amr').installed?
    args << "--enable-libopencore-amrwb" if Formula.factory('opencore-amr').installed?
    args << "--enable-libass" if Formula.factory('libass').installed?
    args << "--disable-ffplay" unless ffplay?

    # For 32-bit compilation under gcc 4.2, see:
    # http://trac.macports.org/ticket/20938#comment:22
    if MacOS.leopard? or Hardware.is_32_bit?
      ENV.append_to_cflags "-mdynamic-no-pic"
    end

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace 'config.mak' do |s|
        shflags = s.get_make_var 'SHFLAGS'
        if shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
          s.change_make_var! 'SHFLAGS', shflags
        end
      end
    end

    system "make install"

    if ARGV.include? "--with-tools"
      system "make alltools"
      bin.install Dir['tools/*'].select {|f| File.executable? f}
    end
  end

end
