require 'formula'

class Soprano <Formula
  @url='http://downloads.sourceforge.net/project/soprano/Soprano/2.3.70/soprano-2.3.70.tar.bz2'
  @homepage='http://soprano.sourceforge.net/'
  @md5='de5cf230a95fc7218425aafdfb4a5e47'

  depends_on 'cmake'
  depends_on 'qt'
  depends_on 'clucene' => :optional
  depends_on 'raptor' => :optional
  depends_on 'redland' => :optional

  def install
    ENV['CLUCENE_HOME'] = HOMEBREW_PREFIX
    
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
