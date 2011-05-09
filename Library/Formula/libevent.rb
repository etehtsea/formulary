require 'formula'

class Libevent < Formula
  url "http://downloads.sourceforge.net/project/levent/libevent/libevent-2.0/libevent-2.0.11-stable.tar.gz"
  homepage 'http://www.monkey.org/~provos/libevent/'
  md5 'bd7ef33c08aa6401c8d67dbc88679ded'
  head 'git://levent.git.sourceforge.net/gitroot/levent/levent'

  fails_with_llvm "Undefined symbol '_current_base' reported during linking.", :build => 2326

  def install
    ENV.j1 # Needed for Mac Pro compilation
    system "./autogen.sh" if ARGV.build_head?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
