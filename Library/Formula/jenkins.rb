require 'formula'

class Jenkins < Formula
  homepage 'http://jenkins-ci.org'
  url 'http://mirrors.jenkins-ci.org/war/1.454/jenkins.war', :using => :nounzip
  version '1.454'
  md5 '6f8bbe0a4bddab9590f65b83cf26744a'
  head 'https://github.com/jenkinsci/jenkins.git'

  def install
    system "mvn clean install -pl war -am -DskipTests && mv war/target/jenkins.war ." if ARGV.build_head?
    lib.install "jenkins.war"
    plist_path.write startup_plist
    plist_path.chmod 0644
  end

  def caveats; <<-EOS
If this is your first install, automatically load on login with:
    mkdir -p ~/Library/LaunchAgents
    cp #{plist_path} ~/Library/LaunchAgents/
    launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

If this is an upgrade and you already have the #{plist_path.basename} loaded:
    launchctl unload -w ~/Library/LaunchAgents/#{plist_path.basename}
    cp #{plist_path} ~/Library/LaunchAgents/
    launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

Or start it manually:
    java -jar #{lib}/jenkins.war
EOS
  end

  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>#{plist_name}</string>
    <key>ProgramArguments</key>
    <array>
    <string>/usr/bin/java</string>
    <string>-jar</string>
    <string>#{HOMEBREW_PREFIX}/lib/jenkins.war</string>
    <string>--httpListenAddress=127.0.0.1</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOS
  end
end
