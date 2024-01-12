let
  pkgs = import <nixpkgs> {};
in
  pkgs.mkShell {
    packages = [
      # sudo
      # docker and docker-compose
      pkgs.gnumake
      pkgs.jq
    ];
  }
