{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay = { url = "github:oxalica/rust-overlay"; };
  };

  outputs = { self, nixpkgs, utils, naersk, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        naersk-lib = pkgs.callPackage naersk { };
      in {
        defaultPackage = naersk-lib.buildPackage ./.;

        defaultApp = utils.lib.mkApp { drv = self.defaultPackage."${system}"; };


        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [ cargo rustc rustfmt pre-commit rustPackages.clippy ]
            ++ lib.optional stdenv.isDarwin [
              darwin.apple_sdk.frameworks.CoreVideo
              darwin.apple_sdk.frameworks.AppKit
              darwin.apple_sdk.frameworks.ApplicationServices
              darwin.apple_sdk.frameworks.Security
              pkgconfig
              openssl
              libiconv
              zld
            ];
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };
      });
}
