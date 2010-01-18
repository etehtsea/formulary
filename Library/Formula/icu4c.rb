require 'formula'

class Icu4c <Formula
  @url='http://download.icu-project.org/files/icu4c/4.3.1/icu4c-4_3_1-src.tgz'
  @homepage='http://site.icu-project.org/'
  @md5='10d1cdc843f8e047fc308ec49d3d0543'
  @version = "4.3.1"
  
  def patches
    DATA
  end

  def keg_only?
    "conflicts (see http://github.com/mxcl/homebrew/issues/#issue/167)."
  end

  def install
    config_flags = ["--prefix=#{prefix}", "--disable-samples", "--enable-static"]
    config_flags << "--with-library-bits=64" if Hardware.is_64_bit? and MACOS_VERSION == 10.6
    Dir.chdir "source" do
      system "./configure", *config_flags
      system "make"
      system "make install"
    end
  end
end


__END__
--- a/source/configure	2009-07-02 03:51:26.000000000 +0900
+++ b/source/configure	2009-08-16 16:15:49.000000000 +0900
@@ -7058,11 +7058,8 @@
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
 
-	# Check for potential -arch flags.  It is not universal unless
-	# there are some -arch flags.  Note that *ppc* also matches
-	# ppc64.  This check is also rather less than ideal.
 	case "${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" in  #(
-	  *-arch*ppc*|*-arch*i386*|*-arch*x86_64*) ac_cv_c_bigendian=universal;;
+	  *-arch*ppc*) ac_cv_c_bigendian=yes;;
 	esac
 else
   $as_echo "$as_me: failed program was:" >&5
