require 'formula'

class Sl < Formula
  url 'http://mirrors.kernel.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  mirror 'http://ftp.us.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  homepage 'http://packages.debian.org/source/stable/sl'
  md5 'd0d997b964bb3478f7f4968eee13c698'

  def install
    inreplace 'Makefile' do |s|
      s.change_make_var! 'CC', ENV.cc
      s.change_make_var! 'CFLAGS', ENV.cflags
    end

    system "make"
    bin.install "sl"
    man1.install "sl.1"
  end
end
