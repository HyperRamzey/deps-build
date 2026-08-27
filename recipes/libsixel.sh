# libsixel — saitoha/libsixel (autotools; PNG loader off: uses libpng 1.4 API
# removed upstream, and mpv only needs the sixel ENCODER)
GIT_URL="https://github.com/saitoha/libsixel"
BUILD() { autotools_driver "$SRC_ROOT/$NAME" --without-png --disable-sixel2png; }
