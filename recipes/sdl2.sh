# SDL2 — libsdl-org/SDL (cmake; shared runtime for ffplay + mpv sdl2-audio/gamepad)
# main branch is SDL3 now; SDL2 lives on release-2.32.x
GIT_URL="https://github.com/libsdl-org/SDL"
GIT_BRANCH="release-2.32.x"
BUILD() {
	cmake_driver "$SRC_ROOT/$NAME" "$BUILD_DIR/$NAME" \
		-DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF \
		-DSDL_DISABLE_INSTALL_DOCS=ON -DSDL_WERROR=OFF
	# static-first house style: shared only (SDL2 runtime model), pc normalized
	[[ -f "$PREFIX/lib/pkgconfig/sdl2.pc" ]] && \
		sed -i "s|^prefix=.*|prefix=$PREFIX|; s|^libdir=.*|libdir=\${prefix}/lib|" \
		"$PREFIX/lib/pkgconfig/sdl2.pc"
	[[ -f "$PREFIX/lib/pkgconfig/sdl2.pc" ]] || { echo "sdl2.pc missing" >>"$LOGF"; return 1; }
}
