require 'formula'

class Fuse4x < Formula
  homepage 'http://fuse4x.org/'
  url 'https://github.com/fuse4x/fuse/tarball/fuse4x_0_10_0'
  md5 '10bacfd8318714de72a95e8baf62d6cd'
  version "0.10.0"

  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on 'gettext'
  depends_on 'fuse4x-kext'

  def install
    # Build universal if the hardware can handle it---otherwise 32 bit only
    MacOS.prefer_64_bit? ? ENV.universal_binary : ENV.m32

    system "autoreconf", "--force", "--install"

    # force 64bit inodes on 10.5. On 10.6+ this is no-op.
    ENV.append_to_cflags "-D_DARWIN_USE_64_BIT_INODE"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-static",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
