require 'formula'

class Gwenhywfar < Formula
  url 'http://www.aquamaniac.de/sites/download/download.php?package=01&release=60&file=01&dummy=gwenhywfar-4.0.9.tar.gz'
  homepage 'http://www.aqbanking.de/'
  md5 '03c22b95eb493c8c98284d3d2e4d9795'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'gnutls'

  def options
    [[
      "--with-gui=XX,...",
      "Install gui support XX where XX is the name of the gui toolkit\n\te.g.: --with-gui=gtk\n\tAvailable gui toolkits are: qt, gtk"
    ]]
  end


  def install
    guis = []
    ARGV.options_only.select { |v| v =~ /--with-gui=/ }.uniq.each do |opt|
      guis << opt.split('=')[1].split(',')
    end

    configure_args = [
      "--prefix=#{prefix}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-guis='#{guis.flatten.join(' ')}'"
    ]

    system "./configure", *configure_args
    system "make install"
  end
end
