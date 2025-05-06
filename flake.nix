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

          jplagjar = "jplag-6.1.0-jar-with-dependencies.jar";

        in with pkgs;
          {
            ###################################################################
            #                             Packages                            #
            ###################################################################
            packages = {
              jplag = stdenv.mkDerivation {
                name = "jplag";

                src = ./.;

                runtimeInputs = [jre_minimal];
                nativeBuildInputs = [ makeWrapper ];

                installPhase = ''
                   mkdir -p $out/bin
                   mkdir -p $out/share
                   cp $src/${jplagjar} $out/share/${jplagjar}
                   makeWrapper ${jre_minimal}/bin/java $out/bin/jplag --add-flags "-jar $out/share/${jplagjar}"
                '';
              };

            };

            ###################################################################
            #                             scripts                             #
            ###################################################################
            apps = {
              default = simple_script "jplag" [] ''
                  ${jre_minimal}/bin/java -jar ${self}/${jplagjar} "''$@"
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
