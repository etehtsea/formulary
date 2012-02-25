require 'formula'

class PcntlPhp < Formula
  homepage 'http://php.net/manual/en/book.pcntl.php'
  url 'http://museum.php.net/php5/php-5.3.6.tar.gz'
  md5 '88a2b00047bc53afbbbdf10ebe28a57e'

  def install
    cd "ext/pcntl" do
      system "phpize"
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make"
      prefix.install "modules/pcntl.so"
    end
  end

  def caveats; <<-EOS.undent
    To finish pcntl-php installation, you need to add the
    following line into php.ini:
      extension="#{prefix}/pcntl.so"
    Then, restart your webserver and check in phpinfo if
    you're able to see something about pcntl.
    EOS
  end
end
