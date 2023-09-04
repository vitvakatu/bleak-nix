{
  description = "brief package description";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:K900/poetry2nix/new-bootstrap-fixes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryPackages;
        packages = ps: with ps;
          [
            (buildPythonPackage
              rec {
                pname = "asyncio";
                version = "3.4.3";
                src = fetchPypi {
                  inherit pname version;
                  sha256 = "sha256-gzYP+LyXmA5P8lyWTHvTkj0zPRd6pPf7c2sBnybHy0E=";
                };
                doCheck = false; # TODO: try to disable?
              })
            ps.pip
            bleak
          ] ++ (mkPoetryPackages {
            projectDir = fetchGit {
              url = "github:/hbldh/bleak";
              rev = "a377ce63766f1910725ada26caad1efe1f7ca281";
            };
            inherit python;
          }).poetryPackages;
      in
      {
        devShells = rec {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              (python.withPackages packages)
            ];
          };
        };
      }
    );
}
