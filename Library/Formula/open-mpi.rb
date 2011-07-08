require 'formula'

class OpenMpi < Formula
  url 'http://www.open-mpi.org/software/ompi/v1.4/downloads/openmpi-1.4.3.tar.gz'
  homepage 'http://www.open-mpi.org/'
  md5 'e7148df2fe5de3e485838bfc94734d6f'

  def install
    # Compiler complains about link compatibility with FORTRAN otherwise
    ENV.delete('CFLAGS')
    ENV.delete('CXXFLAGS')
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
