require 'formula'

class Memcached <Formula
  version '1.4.4'
  url "http://memcached.googlecode.com/files/memcached-#{version}.tar.gz"
  homepage 'http://www.danga.com/memcached/'
  md5 '5ca5b24de347e97ac1f48f3785b4178a'

  depends_on 'libevent'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"

    (prefix+'com.danga.memcached.plist').write startup_plist
  end

  def caveats; <<-EOS
You can enabled memcached to automatically load on login with:
    launchctl load -w #{prefix}/com.danga.memcached.plist

Or start it manually:
    #{HOMEBREW_PREFIX}/bin/memcached

Add "-d" to start it as a daemon.
    EOS
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.danga.memcached</string>
  <key>KeepAlive</key>
  <true/>
  <key>ProgramArguments</key>
  <array>
    <string>#{HOMEBREW_PREFIX}/bin/memcached</string>
    <string>-l 127.0.0.1</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>#{HOMEBREW_PREFIX}</string>
</dict>
</plist>
    EOPLIST
  end
end
