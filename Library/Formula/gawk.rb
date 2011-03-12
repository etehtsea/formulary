require 'formula'

class Gawk < Formula
  url 'http://ftp.gnu.org/gnu/gawk/gawk-3.1.8.tar.bz2'
  homepage 'http://www.gnu.org/software/gawk/'
  md5 '52b41c6c4418b3226dfb8f82076193bb'

  def install
    fails_with_llvm "Undefined symbols when linking", :build => "2326"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
