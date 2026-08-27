# SPIRV-Cross — KhronosGroup (static + c-shared; mpv d3d11 wants spirv-cross-c-shared)
GIT_URL="https://github.com/KhronosGroup/SPIRV-Cross"
BUILD() {
	cmake_driver "$SRC_ROOT/$NAME" "$BUILD_DIR/$NAME" \
		-DSPIRV_CROSS_ENABLE_TESTS=OFF -DSPIRV_CROSS_SHARED=ON \
		-DSPIRV_CROSS_STATIC=ON -DSPIRV_CROSS_CLI=OFF \
		-DSPIRV_CROSS_ENABLE_HLSL=ON -DSPIRV_CROSS_ENABLE_MSL=OFF \
		-DSPIRV_CROSS_ENABLE_REFLECT=ON -DSPIRV_CROSS_ENABLE_UTIL=ON
	# normalize cmake-generated pcs; headers live in include/spirv_cross/
	for pc in spirv-cross-c.pc spirv-cross-c-shared.pc; do
		[[ -f "$PREFIX/lib/pkgconfig/$pc" ]] || continue
		sed -i "s|^prefix=.*|prefix=$PREFIX|; s|^libdir=.*|libdir=\${prefix}/lib|; s|^includedir=.*|includedir=\${prefix}/include|" \
			"$PREFIX/lib/pkgconfig/$pc"
		grep -q "includedir}/spirv_cross" "$PREFIX/lib/pkgconfig/$pc" || \
			sed -i "s|^Cflags: -I\${includedir}|Cflags: -I\${includedir} -I\${includedir}/spirv_cross|" \
			"$PREFIX/lib/pkgconfig/$pc"
	done
	[[ -f "$PREFIX/lib/pkgconfig/spirv-cross-c-shared.pc" ]] || { echo "spirv-cross-c-shared.pc missing" >>"$LOGF"; return 1; }
}
