require 'formula'
require 'hardware'

class V8 <Formula
  head 'http://v8.googlecode.com/svn/trunk/'
  homepage 'http://code.google.com/p/v8/'

  depends_on 'scons'

  def install
    arch = Hardware.is_64_bit? ? 'x64' : 'ia32'

    system "scons",
            "-j #{Hardware.processor_count}",
            "arch=#{arch}",
            "mode=release",
            "snapshot=on",
            "library=shared",
            "visibility=default",
            "console=readline",
            "sample=shell"

    include.install(Dir['include/*'])
    lib.install(Dir['libv8.*'])

    mv('shell', 'v8')
    bin.install('v8')

    system "install_name_tool -change libv8.dylib #{lib}/libv8.dylib #{bin+'v8'}"
  end
end
