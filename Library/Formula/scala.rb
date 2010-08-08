require 'formula'

class Scala <Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/downloads/distrib/files/scala-2.8.0.final.tgz'
  version '2.8.0'
  md5 'f250015d178f05b08bd53baba55c5d46'

  def install
    rm_f Dir["bin/*.bat"]
    man1.install Dir['man/man1/*']
    prefix.install Dir['*']
  end
end
