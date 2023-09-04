{
  description = "brief package description";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject = {
      url = "github:adisbladis/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pyproject }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
        bleakSrc = fetchGit {
          url = "github:hbldh/bleak";
          rev = "a377ce63766f1910725ada26caad1efe1f7ca281";
        };
        bleakProject = pyproject.lib.project.loadPyproject
          {
            pyproject = lib.importTOML "${bleakSrc}/pyproject.toml";
          };
        bleak =
          let
            attrs = pyproject.lib.renderers.buildPythonPackage
              {
                inherit python; project = bleakProject;
                format = "pyproject";
              };
          in
          python.pkgs.buildPythonPackage attrs;
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
          ];
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
