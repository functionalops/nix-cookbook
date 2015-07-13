{ pkgs ? import <nixpkgs> {}
, ... }:
let
  inherit (pkgs) stdenv nix-repl nix-prefetch-scripts;
in
stdenv.mkDerivation {
  name = "nix-cookbook";
  buildInputs = [
    nix-repl
    nix-prefetch-scripts
  ];

  shellHook = ''
    echo "Welcome to the Nix cookbook exercises"
  '';
}
