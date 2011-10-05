require 'formula'

class Clojure < Formula
  url 'http://repo1.maven.org/maven2/org/clojure/clojure/1.3.0/clojure-1.3.0.zip'
  md5 'de91ee9914017a38c7cc391ab8fcbc1a'
  head 'https://github.com/clojure/clojure.git'
  homepage 'http://clojure.org/'

  def script; <<-EOS.undent
    #!/bin/sh
    # Clojure wrapper script.
    # With no arguments runs Clojure's REPL.

    # Put the Clojure jar from the cellar and the current folder in the classpath.
    CLOJURE=$CLASSPATH:#{prefix}/clojure-1.3.0.jar:${PWD}

    if [ "$#" -eq 0 ]; then
        java -cp $CLOJURE clojure.main --repl
    else
        java -cp $CLOJURE clojure.main "$@"
    fi
    EOS
  end

  def install
    system "ant" if ARGV.build_head?
    prefix.install 'clojure-1.3.0.jar'
    (prefix+'classes').mkpath
    (bin+'clj').write script
  end

  def caveats; <<-EOS.undent
    If you `brew install repl` then you may find this wrapper script from
    MacPorts useful:
      http://trac.macports.org/browser/trunk/dports/lang/clojure/files/clj-rlwrap.sh?format=txt
    EOS
  end

  def test
    system "#{bin}/clj -e \"(println \\\"Hello World\\\")\""
  end
end
