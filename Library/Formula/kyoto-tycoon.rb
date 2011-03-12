require 'formula'

class KyotoTycoon < Formula
  url 'http://fallabs.com/kyototycoon/pkg/kyototycoon-0.9.23.tar.gz'
  homepage 'http://fallabs.com/kyototycoon/'
  md5 '115aae62590dd20ed54f6c346cb313cd'

  depends_on 'lua' unless ARGV.include? "--no-lua"
  depends_on 'kyoto-cabinet'

  def options
    [["--no-lua", "Disable Lua support (and don't force Lua install.)"]]
  end

  def install
    args = ["--prefix=#{prefix}"]
    args << "--enable-lua" unless ARGV.include? "--no-lua"

    system "./configure", *args
    system "make"
    system "make install"
  end
end
