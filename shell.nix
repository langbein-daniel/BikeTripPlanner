let
  pkgs = import <nixpkgs> {};
in
  pkgs.mkShell {
    packages = [
      #pkgs.sudo
      pkgs.gnumake
      pkgs.jq
      pkgs.podman-compose
    ];
  }
