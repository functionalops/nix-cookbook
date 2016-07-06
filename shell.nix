{ pkgs ? import <nixpkgs> {}
, ... }:
let

  inherit (pkgs) stdenv nodejs jekyll python27Packages haskellPackages;

  haskell = haskellPackages.ghcWithPackages (p: with p; [
    pandoc
  ]);

in
stdenv.mkDerivation {
  name = "nix-cookbook";
  buildInputs = [
    nodejs
    jekyll
    python27Packages.pygments
    haskell
  ];

  shellHook = ''
  '';
}
