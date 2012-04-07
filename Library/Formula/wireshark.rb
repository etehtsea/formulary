require 'formula'

class Wireshark < Formula
  homepage 'http://www.wireshark.org'
  url 'http://wiresharkdownloads.riverbed.com/wireshark/src/all-versions/wireshark-1.6.7.tar.bz2'
  sha1 '392c4f35cd8d16287ba9eba3afec226fcadd9746'

  devel do
    url 'http://wiresharkdownloads.riverbed.com/wireshark/src/all-versions/wireshark-1.7.1.tar.bz2'
    sha1 '8f49b60c971ffd4857cb05afa82e22152261645f'
  end

  depends_on 'pkg-config' => :build
  depends_on 'gnutls' => :optional
  depends_on 'c-ares' => :optional
  depends_on 'pcre' => :optional
  depends_on 'glib'
  depends_on 'gtk+' if ARGV.include? '--with-x'

  def options
    [
      ['--with-x', 'Include X11 support'],
      ['--with-python', 'Enable experimental python bindings']
    ]
  end

  def install
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]

    # Optionally enable experimental python bindings; is known to cause
    # some runtime issues, e.g.
    # "dlsym(0x8fe467fc, py_create_dissector_handle): symbol not found"
    args << '--without-python' unless ARGV.include? '--with-python'

    # actually just disables the GTK GUI
    args << '--disable-wireshark' unless ARGV.include? '--with-x'

    system "./configure", *args
    system "make"
    ENV.deparallelize # parallel install fails
    system "make install"
  end

  def caveats; <<-EOS.undent
      If your list of available capture interfaces is empty
      (default OS X behavior), try the following commands:

        wget https://bugs.wireshark.org/bugzilla/attachment.cgi?id=3373 -O ChmodBPF.tar.gz
        tar zxvf ChmodBPF.tar.gz
        open ChmodBPF/Install\\ ChmodBPF.app

      This adds a launch daemon that changes the permissions of your BPF
      devices so that all users in the 'admin' group - all users with
      'Allow user to administer this computer' turned on - have both read
      and write access to those devices.

      See bug report:
        https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=3760
    EOS
  end
end

