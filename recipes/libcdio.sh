# libcdio — savannah/libcdio (autotools, in-source) CD-ROM access
GIT_URL="https://git.savannah.gnu.org/git/libcdio.git"
BUILD() {
	# MAKEINFO=true: git checkouts lack generated doc/version.texi (no-op info build).
	# release-2.1.1: man pages only generate in maintainer mode, so disable all
	# CLI tools (we only need the libs); drops previously-unrecognized flags too.
	autotools_driver "$SRC_ROOT/$NAME" \
		--disable-cxx --without-cd-drive --without-cd-info \
		--without-cd-read --without-iso-info --without-iso-read \
		--disable-example-progs --disable-joliet \
		MAKEINFO=true
}
