require 'formula'

class Phonon <Formula
  url 'ftp://ftp.kde.org/pub/kde/stable/phonon/4.4.0/phonon-4.4.0.tgz'
  homepage 'http://phonon.kde.org/'
  md5 '80544b876cf0e0af05f2303b3f534351'

  depends_on 'cmake'
  depends_on 'qt'
  depends_on 'automoc4'

  def patches
    "http://gitorious.org/phonon/phonon/commit/9556b819b089da67290691f53ce7c1550ed23705.patch"
  end
  
  def install
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
