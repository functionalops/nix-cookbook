{ pkgs ? import <nixpkgs> {}
, ... }:
let

  inherit (pkgs) stdenv nodejs jekyll python27Packages;

in
stdenv.mkDerivation {
  name = "nix-cookbook";
  buildInputs = [
    nodejs
    jekyll
    python27Packages.pygments
  ];

  shellHook = ''
  '';
}
