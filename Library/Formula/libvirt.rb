require 'formula'

# This formula provides the libvirt daemon (libvirtd), development libraries, and the
# virsh command line tool.  This allows people to manage their virtualisation servers
# remotely, and (as this continues to be developed) manage virtualisation servers
# running on the local host

class Libvirt < Formula
  homepage 'http://www.libvirt.org'
  if ARGV.build_head?
    url 'http://libvirt.org/sources/libvirt-0.9.1.tar.gz'
    md5 '4182dbe290cca4344a5387950dc06433'
  else
    url 'http://libvirt.org/sources/libvirt-0.8.8.tar.gz'
    sha256 '030aea3728917053555bec98d93d2855e8a603b758c0b2a5d57ac48b4f39e113'
  end

  depends_on "gnutls"
  depends_on "yajl"

  if MacOS.leopard?
    # Definitely needed on Leopard, but not on Snow Leopard.
    depends_on "readline"
    depends_on "libxml2"
  end

  fails_with_llvm "Undefined symbols when linking", :build => "2326"

  def options
    [['--without-libvirtd', 'Build only the virsh client and development libraries.']]
  end

  def install
    args = ["--prefix=#{prefix}",
            "--localstatedir=#{var}",
            "--mandir=#{man}",
            "--sysconfdir=#{etc}",
            "--with-esx",
            "--with-init-script=none",
            "--with-openvz",
            "--with-remote",
            "--with-test",
            "--with-vbox=check",
            "--with-vmware",
            "--with-yajl"]

    args << "--without-libvirtd" if ARGV.include? '--without-libvirtd'

    system "./configure", *args

    # Compilation of docs doesn't get done if we jump straight to "make install"
    system "make"
    system "make install"

    # Update the SASL config file with the Homebrew prefix
    inreplace "#{etc}/sasl2/libvirt.conf" do |s|
      s.gsub! "/etc/", "#{HOMEBREW_PREFIX}/etc/"
      s.gsub! "/var/", "#{HOMEBREW_PREFIX}/var/"
    end

    # If the libvirt daemon is built, update its config file to reflect
    # the Homebrew prefix
    unless ARGV.include? '--without-libvirtd'
      inreplace "#{etc}/libvirt/libvirtd.conf" do |s|
        s.gsub! "/etc/", "#{HOMEBREW_PREFIX}/etc/"
        s.gsub! "/var/", "#{HOMEBREW_PREFIX}/var/"
      end
    end
  end
end
