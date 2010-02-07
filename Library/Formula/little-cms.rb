require 'formula'

class LittleCms <Formula
  url 'http://www.littlecms.com/lcms-1.19.tar.gz'
  homepage 'http://www.littlecms.com/'
  md5 '8af94611baf20d9646c7c2c285859818'
  
  aka 'lcms'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug"
    system "make install"
  end
end
