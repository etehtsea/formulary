require 'formula'

class Trafficserver < Formula
  url 'http://www.apache.org/dyn/closer.cgi/trafficserver/trafficserver-3.0.2.tar.bz2'
  homepage 'http://trafficserver.apache.org/'
  md5 '0f8e5ce658d28511001c6585d1e1813a'

  devel do
    url 'http://www.apache.org/dyn/closer.cgi/trafficserver/trafficserver-3.1.2-unstable.tar.bz2'
    md5 '2208cb9a0d0b7cea07770d51b1cf7df2'
    version '3.1.2'
  end

  depends_on 'pcre'

  def install
    # Needed for correct ./configure detections.
    ENV.enable_warnings
    # Needed for OpenSSL headers on Lion.
    ENV.append_to_cflags "-Wno-deprecated-declarations"
    system "./configure", "--prefix=#{prefix}", "--with-user=#{ENV['USER']}", "--with-group=admin"
    system "make install"
  end

  def test
    system "trafficserver status"
  end
end
