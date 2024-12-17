{
  pkgs,
  lib,
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  rlinkLibs = builtins.attrValues {
    inherit (pkgs)
      pkg-config
      openssl
      ;
    inherit tdlib;
  };
  tdlib = pkgs.callPackage ./tdlib.nix { };
in
pkgs.rustPlatform.buildRustPackage {
  pname = "tgt";
  version = "0-unstable-2024-12-16";

  src = pkgs.fetchFromGitHub {
    owner = "FedericoBruzzone";
    repo = "tgt";
    rev = "b4c99ed03daf0806a14cee108355b9617b6ad7f9";
    sha256 = "sha256-SzIPmelZxwFLCsSkFwb/nhR4uMGkbOO/UjybN053zjE=";
  };

  nativeBuildInputs = rlinkLibs ++ lib.optional isDarwin pkgs.apple-sdk;

  buildInputs = rlinkLibs;

  patches = [ ./patches/0001-check-filesystem-writability-before-operations.patch ];

  doCheck = false;

  cargoHash = "sha256-9xvHkj54+mqWknkoZlPNysY56f8sT8PwLCkAsJWja44=";
  buildNoDefaultFeatures = true;
  buildFeatures = [ "pkg-config" ];

  env = {
    RUSTFLAGS = "-C link-arg=-Wl,-rpath,${tdlib}/lib -L ${pkgs.openssl}/lib";
    LOCAL_TDLIB_PATH = "${tdlib}/lib";
  };

  meta = {
    description = "TUI for Telegram written in Rust";
    homepage = "https://github.com/FedericoBruzzone/tgt";
    license = lib.licenses.free;
    mainProgram = "tgt";
    maintainers = with lib.maintainers; [ donteatoreo ];
  };
}
