require 'formula'

class Libplist < Formula
  homepage 'http://cgit.sukimashita.com/libplist.git/'
  url 'http://cgit.sukimashita.com/libplist.git/snapshot/libplist-1.8.tar.bz2'
  md5 '2a9e0258847d50f9760dc3ece25f4dc6'

  depends_on 'cmake' => :build
  depends_on 'libxml2'

  # Fix 3 Clang compile errors.
  # Similar fixes were made upstream, so verify that these are still needed in 1.9.
  def patches
    DATA
  end

  def install
    ENV.deparallelize # make fails on an 8-core Mac Pro

    # Disable Python bindings.
    inreplace "CMakeLists.txt", 'OPTION(ENABLE_PYTHON "Enable Python bindings (needs Swig)" ON)',
                                '# Disabled Python Bindings'
    system "cmake #{std_cmake_parameters} -DCMAKE_INSTALL_NAME_DIR=#{lib} ."
    system "make install"

    # Remove 'plutil', which duplicates the system-provided one. Leave the versioned one, though.
    rm (bin+'plutil')
  end
end

__END__
--- a/libcnary/node.c	2011-06-24 18:00:48.000000000 -0700
+++ b/libcnary/node.c	2012-01-26 13:59:51.000000000 -0800
@@ -104,7 +104,7 @@
 
 int node_insert(node_t* parent, unsigned int index, node_t* child)
 {
-	if (!parent || !child) return;
+	if (!parent || !child) return 0;
 	child->isLeaf = TRUE;
 	child->isRoot = FALSE;
 	child->parent = parent;
--- a/src/base64.c	2011-06-24 18:00:48.000000000 -0700
+++ b/src/base64.c	2012-01-26 14:01:21.000000000 -0800
@@ -104,9 +104,9 @@
 
 unsigned char *base64decode(const char *buf, size_t *size)
 {
-	if (!buf) return;
+	if (!buf) return NULL;
 	size_t len = strlen(buf);
-	if (len <= 0) return;
+	if (len <= 0) return NULL;
 	unsigned char *outbuf = (unsigned char*)malloc((len/4)*3+3);
 
 	unsigned char *line;
