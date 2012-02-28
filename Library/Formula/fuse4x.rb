require 'formula'

class Fuse4x < Formula
  homepage 'http://fuse4x.org/'
  url 'https://github.com/fuse4x/fuse.git', :tag => "fuse4x_0_8_14"
  version "0.8.14"

  depends_on 'gettext'
  depends_on 'fuse4x-kext'

  if MacOS.xcode_version >= "4.3"
    depends_on "automake"
    depends_on "libtool"
  end

  def install
    # Build universal if the hardware can handle it---otherwise 32 bit only
    MacOS.prefer_64_bit? ? ENV.universal_binary : ENV.m32

    system "autoreconf", "--force", "--install"

    system "./configure", "--disable-dependency-tracking", "--disable-debug", "--disable-static", "--prefix=#{prefix}"
    system "make install"
  end
end
