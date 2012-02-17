require 'formula'

class Binutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz'
  mirror 'http://ftp.club.cc.cmu.edu/pub/gnu/binutils/binutils-2.22.tar.gz'
  md5 '8b3ad7090e3989810943aa19103fdb83'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--program-prefix=g",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror",
                          "--enable-interwork",
                          "--enable-multilib",
                          "--enable-targets=x86_64-elf",
                          "--enable-targets=arm-none-eabi"
    system "make"
    system "make install"
  end
end
