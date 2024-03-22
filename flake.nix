{
  description = "jplag";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          # import nix packages
          pkgs = import nixpkgs {
            inherit system;
          };

          # Utility to run a script easily in the flakes app
          simple_script = name: add_deps: text: let
            exec = pkgs.writeShellApplication {
              inherit name text;
              runtimeInputs = with pkgs; [
                jre_minimal
              ] ++ add_deps;
            };
          in {
            type = "app";
            program = "${exec}/bin/${name}";
          };

        in with pkgs;
          {
            ###################################################################
            #                             scripts                             #
            ###################################################################
            apps = {
              default = simple_script "jplag" [] ''
                  java -jar ${self}/jplag-4.2.0-jar-with-dependencies.jar "''$@"
              '';

            };

            ###################################################################
            #                       development shell                         #
            ###################################################################
            devShells.default =
              mkShell
                {
                  nativeBuildInputs = with pkgs; [
                    jre_minimal
                    charasay
                  ];
                  shellHook = ''
                      echo "${jre_minimal}" | chara say
                  '';
                };
          }
      );
}
