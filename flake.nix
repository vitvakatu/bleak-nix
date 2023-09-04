{
  description = "brief package description";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryPackages;
        python = pkgs.python311;
        packages = ps: with ps; [
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
          # (buildPythonPackage
          #   rec {
          #     pname = "bleak";
          #     version = "0.21.0";
          #     format = "pyproject";
          #     src = fetchPypi {
          #       inherit pname version;
          #       sha256 = "sha256-InqIt4gx5uIyKpviCdzmYoF3OCiF4wZfvpwlRFqbrnk=";
          #     };
          #     nativeBuildInputs = [ ps.poetry-core ];
          #   })
          # ps.typing-extensions
          ps.pip
        ];
        # ++
        # (mkPoetryPackages
        #   {
        #     projectDir = fetchGit {
        #       url = "https://github.com/hbldh/bleak";
        #       rev = "a377ce63766f1910725ada26caad1efe1f7ca281";
        #     };
        #     inherit python;
        #   }).poetryPackages;
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
