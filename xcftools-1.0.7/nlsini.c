#include "xcftools.h"
#ifndef nls_init
void nls_init(void) {
  bindtextdomain("xcftools","/usr/local/share/locale");
  textdomain("xcftools"); }
#endif
