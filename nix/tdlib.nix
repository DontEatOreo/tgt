{
  fetchFromGitHub,
  gperf,
  openssl,
  readline,
  zlib,
  cmake,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tdlib";
  version = "1.8.29";

  src = fetchFromGitHub {
    owner = "tdlib";
    repo = "td";

    # The tdlib authors do not set tags for minor versions, but
    # external programs depending on tdlib constrain the minor
    # version, hence we set a specific commit with a known version.
    rev = "af69dd4397b6dc1bf23ba0fd0bf429fcba6454f6";
    hash = "sha256-2RhKSxy0AvuA74LHI86pqUxv9oJZ+ZxxDe4TPI5UYxE=";
  };

  buildInputs = [
    gperf
    openssl
    readline
    zlib
  ];
  nativeBuildInputs = [ cmake ];

  # https://github.com/tdlib/td/issues/1974
  postPatch =
    ''
      substituteInPlace CMake/GeneratePkgConfig.cmake \
        --replace 'function(generate_pkgconfig' \
                  'include(GNUInstallDirs)
                   function(generate_pkgconfig' \
        --replace '\$'{prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
        --replace '\$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
    ''
    + lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
      sed -i "/vptr/d" test/CMakeLists.txt
    '';

  meta = with lib; {
    description = "Cross-platform library for building Telegram clients";
    homepage = "https://core.telegram.org/tdlib/";
    license = lib.licenses.boost;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      vyorkin
      vonfry
    ];
  };
})
