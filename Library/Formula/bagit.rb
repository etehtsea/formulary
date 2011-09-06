require 'formula'

class Bagit < Formula
  url 'http://downloads.sourceforge.net/project/loc-xferutils/loc-bil-java-library/3.13/bagit-3.13-bin.zip'
  homepage 'http://sourceforge.net/project/loc-xferutils'
  md5 'ff5bbbe554a2cb70cc1881f925850a28'

  skip_clean 'logs'

  def install
    prefix.install %w{ LICENSE.txt README.txt conf logs}
    libexec.install Dir['lib/*']
    inreplace "bin/bag", "$APP_HOME/lib", "$APP_HOME/libexec"
    inreplace "bin/bag.classworlds.conf", "${app.home}/lib", "${app.home}/libexec"
    rm "bin/bag.bat"
    bin.install Dir['bin/*']
  end
end
