/* x86s running Linux */

#include <string.h>

static char rcsid[] = "$Id$";

#ifndef LCCDIR
#define LCCDIR "/home/chihiro/usr/local/lcc/bin/"
#endif

#define CPPDIR "/bin/"
#define TOOLDIR "/home/chihiro/usr/local/sun32-unknown-elf/bin/"
#define LDDIR TOOLDIR
#define ASDIR TOOLDIR

char *suffixes[] = { ".c", ".i", ".s", ".o", ".out", 0 };
char inputs[256] = "";
char *cpp[] = { CPPDIR "cpp",
	"", "", "", "",
	"", "", "",
	"", "", "", "-D__signed__=signed",
	"$1", "$2", "$3", 0 };
char *include[] = {"-I" LCCDIR, 0 };
char *com[] = {LCCDIR "rcc", "-target=sun", "$1", "$2", "$3", 0 };
char *as[] = { TOOLDIR "as", "-o", "$3", "$1", "$2", 0 };
char *ld[] = {
	/*  0 */ TOOLDIR "ld", "", "", "-static",
	/*  4 */ "", "-o", "$3",
	/*  7 */ "", "",
	/*  9 */ "", 
                 "$1", "$2",
	/* 12 */ "",
	/* 13 */ "",
	/* 14 */ "", "", "", "",
	/* 18 */ "",
	/* 19 */ "", "",
	0 };

extern char *concat(char *, char *);

int option(char *arg) {
	return 1;
}
