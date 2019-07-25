/* x86s running Linux */

#include <string.h>

static char rcsid[] = "$Id$";

//#define CPPDIR LCCDIR"/"PREFIX"/"
#define INSTDIR "/opt/sun32_toolchain"
#define CPPDIR INSTDIR"/lcc/bin"
#define BINUTILSDIR  INSTDIR"/binutils/bin"
#define LCCDIR INSTDIR"/lcc/bin"
#define LIBDIR INSTDIR"/lib/lcc"
#define INCDIR INSTDIR"/lib/include"
#define PREFIX "sun32-unknown-elf-"

char *suffixes[] = { ".c", ".i", ".s", ".o", ".out", 0 };
char inputs[256] = "";
char *cpp[] = { 
	/*CPPDIR"/"PREFIX"cpp",*/
	"/usr/bin/cpp",
	"-D__signed__=signed",
	"-I",
	"$1",
	"$2", 
	"$3", 
	0 
};
char *include[] = {"-I"INCDIR, 0 };
char *com[] = {
	LCCDIR"/"PREFIX"rcc", 
	"-target=sun", 
	"$1", 
	"$2", 
	"$3", 
	0
};
char *as[] = {
	BINUTILSDIR"/"PREFIX"as", 
	"-o", 
	"$3", 
	"$1", 
	"$2", 
	0 
};
char *ld[] = {
	BINUTILSDIR"/"PREFIX"ld", "", "", "-static",
	"-o", 
	"$3",
	""
	"$1", 
	"$2",
	"-L" LIBDIR,
	"",
	0 
};

extern char *concat(char *, char *);

int option(char *arg) {
	if(strcmp(arg, "-T") == 0) {
		ld[3] = concat("-T ", &arg[4]);
	} else {
		return 0;
	}
	return 1;
}
