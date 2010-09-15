require 'formula'

class Gradle <Formula
  homepage 'http://www.gradle.org/'
  url 'http://dist.codehaus.org/gradle/gradle-0.8-all.zip'
  head 'http://dist.codehaus.org/gradle/gradle-0.9-rc-1-all.zip'

  if ARGV.build_head?
    version '0.9-rc-1'
    md5 'f216f7a76ca097a310ab653d839980c0'
  else
    version '0.8'
    md5 '73a0ed51b6ec00a7d3a9d242d51aae60'
  end

  def install
    rm_f Dir["bin/*.bat"]

    if ARGV.build_head?
      libexec.install %w[bin lib]
    else
      libexec.install %w[bin lib gradle-imports plugin.properties]
    end

    bin.mkpath
    ln_s libexec+('bin/gradle'), bin
  end
end
