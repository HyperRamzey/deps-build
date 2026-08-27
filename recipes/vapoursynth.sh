# vapoursynth — vapoursynth/vapoursynth (meson; python3 host tools) [BEST-EFFORT]
# Builds SHARED (python-embedding model); everything else in deps stays static.
GIT_URL="https://github.com/vapoursynth/vapoursynth"
BUILD() {
	meson_driver "$SRC_ROOT/$NAME" "$BUILD_DIR/$NAME" \
		-Ddefault_library=shared -Denable_x86_asm=true \
		-Denable_guard_pattern=false
	# Upstream now installs EVERYTHING into python site-packages (wheel-style
	# layout). Relocate what FFmpeg needs into the canonical prefix: headers
	# (configure's require_headers), DLLs (runtime dlopen; copydlls ships
	# deps-<t>/bin), import libs + a sane .pc for completeness.
	local sp
	sp="$(ls -d "$PREFIX"/lib/python3.*/site-packages/vapoursynth 2>/dev/null | head -1)"
	[[ -n "$sp" ]] || { echo "vapoursynth: site-packages dir not found" >>"$LOGF"; return 1; }
	mkdir -p "$PREFIX/include/vapoursynth"
	cp -f "$sp"/include/*.h "$PREFIX/include/vapoursynth/" >>"$LOGF" 2>&1
	cp -f "$sp"/*.dll "$PREFIX/bin/" >>"$LOGF" 2>&1
	cp -f "$sp"/*.dll.a "$PREFIX/lib/" >>"$LOGF" 2>&1
	{
		echo "prefix=$PREFIX"
		echo "includedir=\${prefix}/include"
		echo "libdir=\${prefix}/lib"
		echo ""
		echo "Name: vapoursynth"
		echo "Description: A frameserver for the 21st century"
		echo "Version: $(sed -n 's/^Version: //p' "$sp/pkgconfig/vapoursynth.pc")"
		echo "Libs: -L\${libdir} -lvapoursynth"
		# Both include roots: FFmpeg includes <vapoursynth/VSScript4.h>
		# (needs -Iincludedir), mpv includes <VSScript4.h> flat (needs
		# -Iincludedir/vapoursynth). Emit both so either resolves.
		echo "Cflags: -I\${includedir} -I\${includedir}/vapoursynth"
	} > "$PREFIX/lib/pkgconfig/vapoursynth.pc"
}
BEST_EFFORT=1
