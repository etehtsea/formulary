require 'formula'

class ScalaDocs < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/downloads/distrib/files/scala-2.9.0.1-devel-docs.tgz'
  head 'http://www.scala-lang.org/downloads/distrib/files/scala-2.9.0.1-devel-docs.tgz'
  version '2.9.0.1'

  if ARGV.build_head?
    md5 'acb16cbdf46f682806f60b052707b7b7'
  else
    md5 'acb16cbdf46f682806f60b052707b7b7'
  end
end

class Scala < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/downloads/distrib/files/scala-2.9.0.1.tgz'
  head 'http://www.scala-lang.org/downloads/distrib/files/scala-2.9.0.1.tgz'
  version '2.9.0.1'

  if ARGV.build_head?
    md5 '10d01410fd75019fa21a88964462a077'
  else
    md5 '10d01410fd75019fa21a88964462a077'
  end

  def options
    [['--with-docs', 'Also install library documentation']]
  end

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir['doc/*']
    man1.install Dir['man/man1/*']
    libexec.install Dir['*']
    bin.mkpath
    Dir["#{libexec}/bin/*"].each { |f| ln_s f, bin }

    if ARGV.include? '--with-docs'
      ScalaDocs.new.brew { doc.install Dir['*'] }
    end
  end
end
