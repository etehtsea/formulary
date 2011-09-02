require 'formula'
require 'hardware'

class Mongodb < Formula
  homepage 'http://www.mongodb.org/'

  if ARGV.build_head?
    packages = {
      :x86_64 => {
        :url => 'http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.0.0-rc1.tgz',
        :md5 => '499f140eb8ba2b7642e3823233fe11d3',
        :version => '2.0.0-rc1-x86_64'
      },
      :i386 => {
        :url => 'http://fastdl.mongodb.org/osx/mongodb-osx-i386-2.0.0-rc1.tgz',
        :md5 => 'beac32bb35cf7d752c576c95173a3fd3',
        :version => '2.0.0-rc1-i386'
      }
    }
  else
    packages = {
      :x86_64 => {
        :url => 'http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-1.8.3.tgz',
        :md5 => '8bdb3e110d6391d66379c5425c1c4e6e',
        :version => '1.8.3-x86_64'
      },
      :i386 => {
        :url => 'http://fastdl.mongodb.org/osx/mongodb-osx-i386-1.8.3.tgz',
        :md5 => '5629e49d6d24a99850fb094efb98685c',
        :version => '1.8.3-i386'
      }
    }
  end

  package = (Hardware.is_64_bit? and not ARGV.include? '--32bit') ? packages[:x86_64] : packages[:i386]

  url     package[:url]
  md5     package[:md5]
  version package[:version]

  skip_clean :all

  def options
    [
        ['--32bit', 'Override arch detection and install the 32-bit version.'],
        ['--nojournal', 'Disable write-ahead logging (Journaling)'],
        ['--rest', 'Enable the REST Interface on the HTTP Status Page'],
    ]
  end

  def install
    # Copy the prebuilt binaries to prefix
    prefix.install Dir['*']

    # Create the data and log directories under /var
    (var+'mongodb').mkpath
    (var+'log/mongodb').mkpath

    # Write the configuration files and launchd script
    (prefix+'mongod.conf').write mongodb_conf
    (prefix+'org.mongodb.mongod.plist').write startup_plist
    (prefix+'org.mongodb.mongod.plist').chmod 0644
  end

  def caveats
    s = ""
    s += <<-EOS.undent
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp #{prefix}/org.mongodb.mongod.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.mongodb.mongod.plist

    If this is an upgrade and you already have the org.mongodb.mongod.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/org.mongodb.mongod.plist
        cp #{prefix}/org.mongodb.mongod.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.mongodb.mongod.plist

    Or start it manually:
        mongod run --config #{prefix}/mongod.conf
    EOS

    if ARGV.include? "--nojournal"
        s += ""
        s += <<-EOS.undent
        Write Ahead logging (Journaling) has been disabled.
        EOS
    else
        s += ""
        s += <<-EOS.undent
        MongoDB 1.8+ includes a feature for Write Ahead Logging (Journaling), which has been enabled by default.
        This is not the default in production (Journaling is disabled); to disable journaling, use --nojournal.
        EOS
    end

    return s
  end

  def mongodb_conf
    conf = ""
    conf += <<-EOS.undent
    # Store data in #{var}/mongodb instead of the default /data/db
    dbpath = #{var}/mongodb

    # Only accept local connections
    bind_ip = 127.0.0.1
    EOS

    if ARGV.build_head?
      if ARGV.include? '--nojournal'
        conf += <<-EOS.undent
        # Enable Write Ahead Logging (not enabled by default in production deployments)
        nojournal = true
        EOS
      end
    else
      unless ARGV.include? '--nojournal'
        conf += <<-EOS.undent
        # Enable Write Ahead Logging (not enabled by default in production deployments)
        journal = true
        EOS
      end
    end

    if ARGV.include? '--rest'
        conf += <<-EOS.undent
        # Enable the REST interface on the HTTP Console (startup port + 1000)
        rest = true
        EOS
    end

    return conf
  end

  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.mongodb.mongod</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{bin}/mongod</string>
    <string>run</string>
    <string>--config</string>
    <string>#{prefix}/mongod.conf</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
  <key>UserName</key>
  <string>#{`whoami`.chomp}</string>
  <key>WorkingDirectory</key>
  <string>#{HOMEBREW_PREFIX}</string>
  <key>StandardErrorPath</key>
  <string>#{var}/log/mongodb/output.log</string>
  <key>StandardOutPath</key>
  <string>#{var}/log/mongodb/output.log</string>
</dict>
</plist>
EOS
  end
end
