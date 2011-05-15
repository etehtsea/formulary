require 'formula'

class Ttytter < ScriptFileFormula
  url 'http://www.floodgap.com/software/ttytter/dist1/1.1.11.txt'
  homepage 'http://www.floodgap.com/software/ttytter/'
  md5 '50bea21abc5e6dfb5d1636fdb4ddbf13'

  def install
    bin.install '1.1.11.txt' => 'ttytter'
  end

  def caveats; <<-EOS.undent
      To take full advantage of readline features you must install readline:
          brew install readline

      and the Perl Module Term::ReadLine::TTYtter
          cpan -i Term::ReadLine::TTYtter

      Or if you have cpanminus:
          cpanm Term::ReadLine::TTYtter
    EOS
  end
end
