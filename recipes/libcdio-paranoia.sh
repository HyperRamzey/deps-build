# libcdio-paranoia — rocky/libcdio-paranoia (autotools, in-source) CDDA extraction
GIT_URL="https://github.com/rocky/libcdio-paranoia"
BUILD() {
	# autoconf 2.72's AC_PROG_CC bakes -std=gnu23 into CC; the bundled K&R
	# getopt.h ("extern int getopt();") is invalid in C23. Last -std wins on
	# the command line, so force gnu17 via CFLAGS.
	CFLAGS="$CFLAGS -std=gnu17" autotools_driver "$SRC_ROOT/$NAME" \
		--disable-example-progs --with-libcdio-prefix="$PREFIX"
}
