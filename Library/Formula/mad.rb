require 'formula'

class Mad <Formula
  homepage 'http://www.underbit.com/products/mad/'
  url 'http://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz'
  md5 '1be543bc30c56fb6bea1d7bf6a64e66c'

  def mad_pc
    return <<-EOS
prefix=#{HOMEBREW_PREFIX}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: mad
Description: MPEG Audio Decoder
Version: #{@version}
Requires:
Conflicts:
Libs: -L${libdir} -lmad -lm
Cflags: -I${includedir}
    EOS
  end

  def install
    if MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
      fpm = '64bit'
    else
      fpm = 'intel'
    end

    system "./configure", "--disable-debugging", "--enable-fpm=#{fpm}", "--prefix=#{prefix}"

    # See: http://github.com/mxcl/homebrew/issues/issue/1263
    inreplace "Makefile" do |s|
      s.change_make_var! "CFLAGS", ENV['CFLAGS']
      s.change_make_var! "LDFLAGS", ENV['LDFLAGS']
    end

    system "make install"

    (lib+'pkgconfig/mad.pc').write mad_pc
  end
end
