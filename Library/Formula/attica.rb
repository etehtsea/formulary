require 'formula'

class Attica < Formula
  homepage 'http://www.kde.org/'
  url 'ftp://ftp.kde.org/pub/kde/stable/attica/attica-0.2.0.tar.bz2'
  md5 'df3dcea0229cfa31539bdd427976e15b'

  depends_on 'cmake' => :build

  def install
    system "cmake #{std_cmake_parameters} ."
    system "make install"
  end
end
