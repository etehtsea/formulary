require 'formula'

class Clisp < Formula
  url 'http://ftpmirror.gnu.org/clisp/release/2.49/clisp-2.49.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/clisp/release/2.49/clisp-2.49.tar.bz2'
  homepage 'http://clisp.cons.org/'
  md5 '1962b99d5e530390ec3829236d168649'

  depends_on 'libiconv'
  depends_on 'libsigsegv'
  depends_on 'readline'

  skip_clean :all # otherwise abort trap

  fails_with_llvm "Configure fails on XCode 4/Snow Leopard.", :build => 2334

  def patches
    { :p0 => "https://trac.macports.org/export/89054/trunk/dports/lang/clisp/files/patch-src_lispbibl_d.diff" }
  end

  def install
    ENV.j1 # This build isn't parallel safe.
    ENV.remove_from_cflags /-O./

    # Clisp requires to select word size explicitly this way,
    # set it in CFLAGS won't work.
    ENV['CC'] = "#{ENV.cc} -m#{MacOS.prefer_64_bit? ? 64 : 32}"

    system "./configure", "--prefix=#{prefix}",
                          "--with-readline=yes"

    cd "src" do
      # Multiple -O options will be in the generated Makefile,
      # make Homebrew's the last such option so it's effective.
      inreplace "Makefile" do |s|
        cf = s.get_make_var("CFLAGS")
        cf.gsub! ENV['CFLAGS'], ''
        cf += ' '+ENV['CFLAGS']
        s.change_make_var! 'CFLAGS', cf
      end

      # The ulimit must be set, otherwise `make` will fail and tell you to do so
      system "ulimit -s 16384 && make"

      if MacOS.lion?
        opoo "`make check` fails on Lion, so we are skipping it."
        puts "But it probably means there will be other issues too."
        puts "Please take them upstream to the clisp project itself."
      else
        # Considering the complexity of this package, a self-check is highly recommended.
        system "make check"
      end

      system "make install"
    end
  end

  def test
    system "#{bin}/clisp --version"
  end
end
