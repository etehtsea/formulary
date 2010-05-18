require 'formula'

class XapianBindings <Formula
  url 'http://oligarchy.co.uk/xapian/1.0.20/xapian-bindings-1.0.20.tar.gz'
  homepage 'http://xapian.org'
  md5 '8ba9d695d5646501efd547debe37f086'
end

class Xapian <Formula
  url 'http://oligarchy.co.uk/xapian/1.0.20/xapian-core-1.0.20.tar.gz'
  homepage 'http://xapian.org'
  md5 'fd3980da28be014a5ac29e40fa1fbbac'

  def options
    [
      ["--ruby", "Ruby bindings"],
      ["--python", "Python bindings"],
      ["--php", "PHP bindings"],
      ["--java", "Java bindings"],
    ]
  end

  def skip_clean? path
    path.extname == '.la'
  end

  def install
    ENV.O3 # takes forever otherwise

    system "./configure", "--prefix=#{prefix}", "--disable-assertions",
                          "--disable-dependency-tracking"
    system "make install"

    XapianBindings.new.brew do
      if ARGV.include? '--ruby' or ARGV.include? '--python' or ARGV.include? '--java' or ARGV.include? '--php'
        args = [
          "XAPIAN_CONFIG=#{bin}/xapian-config",
          "--prefix=#{prefix}",
          "--disable-debug",
          "--disable-dependency-tracking",
          "--without-csharp",
          "--without-tcl"
        ]
        if ARGV.include? '--ruby'
          args << "--with-ruby"
        else
          args << "--without-ruby"
        end
        if ARGV.include? '--python'
          args << "--with-python"
        else
          args << "--without-python"
        end
        if ARGV.include? '--php'
          lib.mkdir
          extension_dir = (lib+'php'+'extensions')
          extension_dir.mkdir
          args << "--with-php PHP_EXTENSION_DIR=#{extension_dir}"
        else
          args << "--without-php"
        end
        if ARGV.include? '--java'
          args << "--with-java"
        else
          args << "--without-java"
        end
        system "./configure", *args
        system "make install"
      end
    end
  end
end
