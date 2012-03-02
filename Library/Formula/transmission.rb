require 'formula'

class Transmission < Formula
  homepage 'http://www.transmissionbt.com/'
  url 'http://download.transmissionbt.com/files/transmission-2.50.tar.bz2'
  md5 'c3611108e34fe6ebdcf93da5beb89045'

  # Actually depends on libcurl but doesn't find it without pkg-config
  depends_on 'pkg-config' => :build
  depends_on 'libevent'
  depends_on 'intltool' => :optional
  depends_on 'gettext' => :optional # need gettext only if intltool is also installed

  def install
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--disable-mac",
            "--without-gtk"]

    args << "--disable-nls" unless Formula.factory("intltool").installed? and
                                   Formula.factory("gettext").installed?

    system "./configure", *args
    system "make" # build fails for some reason if make isn't done first
    system "make install"
  end

  def caveats; <<-EOS.undent
    This formula only installs the Transmission command line utilities:
      transmission-cli
      transmission-create
      transmission-daemon
      transmission-edit
      transmission-remote
      transmission-show

    Transmission.app can be downloaded from Transmission's website.
    EOS
  end
end
