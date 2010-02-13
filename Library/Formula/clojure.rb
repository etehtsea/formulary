require 'formula'

class Clojure <Formula
  url 'http://clojure.googlecode.com/files/clojure-1.1.0.zip'
  md5 '9c9e92f85351721b76f40578f5c1a94a'
  head 'git://github.com/richhickey/clojure.git'
  homepage 'http://clojure.org/'
  JAR = "clojure.jar"

  def script
    DATA.read.gsub 'CLOJURE_JAR_PATH_PLACEHOLDER', "$(brew --prefix)/Cellar/#{name}/#{version}/"+JAR
  end

  def install
    prefix.install JAR
    (bin+'clj').write(script)
  end
end

__END__
#!/bin/bash
# Runs clojure.
# With no arguments, runs Clojure's REPL.
# With one or more arguments, the first is treated as a script name, the rest
# passed as command-line arguments.

# resolve links - $0 may be a softlink
CLOJURE=$CLASSPATH:CLOJURE_JAR_PATH_PLACEHOLDER

if [ -z "$1" ]; then
  java -server -cp $CLOJURE clojure.main
else
  scriptname=$1
  java -server -cp $CLOJURE clojure.main $scriptname $*
fi
