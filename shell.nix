let
  pkgs = import <nixpkgs> { };
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix/";
    ref = "master";
  }) { python = "python37"; };
  customPython = mach-nix.mkPython rec {
    providers._default = "wheel,conda,nixpkgs,sdist";
    requirements = builtins.readFile ./requirements.txt; 
  };
in pkgs.mkShell { buildInputs = [ customPython ]; }
