#!/bin/bash
# fix-static-pcs.sh <prefix> — ensure Libs.private carries the C++ runtime
# (-lc++ -lunwind) for every static archive that actually needs it. Meson/cmake
# don't emit these, which breaks consumers' single-lib pkg-config link tests
# (ffmpeg configure). Also strips GNU -lstdc++ residue (libc++ toolchain).
# Idempotent.
PREFIX="${1:?usage: fix-static-pcs.sh <deps-prefix>}"
PCDIR="$PREFIX/lib/pkgconfig"
[[ -d "$PCDIR" ]] || exit 0
fixed=0
for a in "$PREFIX"/lib/*.a; do
	name="$(basename "$a" .a)"          # e.g. libopenh264
	# shaderc's pc is consumed only by libplacebo, whose meson links the
	# static libc++.a by full path itself; -lc++ here would resolve to
	# libc++.dll.a (import lib) -> duplicate C++ runtime symbols at link
	case "$name" in libshaderc*) continue ;; esac
	pc=""
	for cand in "$PCDIR/$name.pc" "$PCDIR/${name#lib}.pc" \
		"$PCDIR/$(echo "${name#lib}" | tr "A-Z" "a-z").pc"; do
		[[ -f "$cand" ]] && { pc="$cand"; break; }
	done
	[[ -n "$pc" ]] || continue
	# does the archive contain C++ runtime references? (exceptions, std, new/delete)
	if nm "$a" 2>/dev/null | grep -qE "__cxa_|_ZSt|_Znwm|_ZdlPv|_ZdaPv"; then
		if ! grep -q -- "-lc++" "$pc"; then
			if grep -q "^Libs.private:" "$pc"; then
				sed -i "s| -lstdc++||; s|^Libs.private:|Libs.private: -lc++ -lunwind|" "$pc"
			else
				echo "Libs.private: -lc++ -lunwind" >> "$pc"
			fi
			fixed=$((fixed+1))
			echo "fix-static-pcs: $name -> -lc++ -lunwind"
		fi
	fi
done
echo "fix-static-pcs: $fixed pc files patched"