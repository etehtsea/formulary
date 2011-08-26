require 'formula'

class Ffmpeg < Formula
  url 'http://ffmpeg.org/releases/ffmpeg-0.8.2.tar.bz2'
  homepage 'http://ffmpeg.org/'
  sha1 '984f731aced1380840cd8e3576e8db0c2fd5537f'

  head 'git://git.videolan.org/ffmpeg.git'

  depends_on 'yasm' => :build
  depends_on 'x264' => :optional
  depends_on 'faac' => :optional
  depends_on 'lame' => :optional
  depends_on 'theora' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'libogg' => :optional
  depends_on 'libvpx' => :optional
  depends_on 'xvid' => :optional

  def install
    args = ["--prefix=#{prefix}",
            "--enable-shared",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            "--enable-hardcoded-tables"]

    args << "--enable-libx264" if Formula.factory('x264').installed?
    args << "--enable-libfaac" if Formula.factory('faac').installed?
    args << "--enable-libmp3lame" if Formula.factory('lame').installed?
    args << "--enable-libtheora" if Formula.factory('theora').installed?
    args << "--enable-libvorbis" if Formula.factory('libvorbis').installed?
    args << "--enable-libvpx" if Formula.factory('libvpx').installed?
    args << "--enable-libxvid" if Formula.factory('xvid').installed?

    # Force use of clang on Lion
    # See: https://avcodec.org/trac/ffmpeg/ticket/353
    if MacOS.lion?
      args << "--cc=clang"
    else
      args << case ENV.compiler
        when :clang then "--cc=clang"
        when :llvm then "--cc=llvm-gcc"
        when :gcc then "--cc=gcc"
      end
    end

    # For 32-bit compilation under gcc 4.2, see:
    # http://trac.macports.org/ticket/20938#comment:22
    if MacOS.snow_leopard? and Hardware.is_32_bit?
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

    write_version_file if ARGV.build_head?

    system "make install"
  end

  # Makefile expects to run in git repo and generate a version number
  # with 'git describe' command (see version.sh) but Homebrew build
  # runs in temp copy created via git checkout-index, so 'git describe'
  # does not work. Work around by writing VERSION file in build directory
  # to be picked up by version.sh.  Note that VERSION file will already
  # exist in release versions, so this only applies to git HEAD builds.
  def write_version_file
    return if File.exists?("VERSION")
    git_tag = "UNKNOWN"
    Dir.chdir(cached_download) do
      ver = `./version.sh`.chomp
      if not $?.success? or ver == "UNKNOWN"
        # fall back to git
        ver = `git describe --tags --match N --always`.chomp
        if not $?.success?
          opoo "Could not determine build version from git repository - set to #{git_tag}"
        else
          git_tag = "git-#{ver}"
        end
      else
        git_tag = ver
      end
    end
    File.open("VERSION","w") {|f| f.puts git_tag}
  end

end
