require 'formula'

class Metasploit < Formula
  url "https://www.metasploit.com/svn/framework3/trunk/", :using => :svn, :revision => "9321"
  head "https://www.metasploit.com/svn/framework3/trunk/", :using => :svn
  version "3.4.0"
  homepage 'http://www.metasploit.com/framework/'

  def install
    libexec.install Dir["msf*",'data','external','lib','modules','plugins','scripts','test','tools']
    bin.mkpath
    Dir["#{libexec}/msf*"].each {|f| ln_s f, bin}
  end
end
