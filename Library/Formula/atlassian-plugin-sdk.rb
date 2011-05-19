require 'formula'

class AtlassianPluginSdk < Formula
  url 'https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/amps/atlassian-plugin-sdk/3.3.3/atlassian-plugin-sdk-3.3.3.tar.gz'
  homepage 'http://confluence.atlassian.com/display/DEVNET/Setting+up+your+Plugin+Development+Environment'
  md5 'bd43121ee2ae7e0e691efd004fbb82af'

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    Dir.chdir "apache-maven/maven-docs" do
      prefix.install %w{ NOTICE.txt LICENSE.txt README.txt }
    end

    # Install jars in libexec to avoid conflicts
    libexec.install Dir['*']

    # Symlink binaries
    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      ln_s f, bin+File.basename(f)
    end
  end

  def caveats; <<-EOS.undent
      Create a plugin skeleton using atlas-create-APPLICATION-plugin, e.g.:
        atlas-create-confluence-plugin

      To run your plugin's host application with the plugin skeleton installed:
        atlas-run
    EOS
  end
end
