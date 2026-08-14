{
  description = "";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.gamemaker-flake = {
    url = "github:skirlez/gamemaker-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.vs = {
    url = "path:dummy";
    flake = false;
  };
  outputs =
    {
      self,
      nixpkgs,
      gamemaker-flake,
      vs,
    }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      srcWithAssets =
        pkgs.lib.throwIfNot (builtins.pathExists vs)
          "You must override the input \"vs\" with the path an (unmodified) Void Stranger installation."
          pkgs.stdenvNoCC.mkDerivation
          {
            name = "ev-src-with-assets";
            src = ./.;
            nativeBuildInputs = [
              pkgs.undertalemodcli
            ];
            unpackPhase = ''
              mkdir -p $out
              cp -r $src/* $out
              chmod -R u+w $out

              cd $out/g3man
              UndertaleModCli load ${vs}/data.win --scripts copy-game-assets.csx
            '';
            strictDeps = true;
          };

      endless-void = gamemaker-flake.packages.x86_64-linux.buildGameMakerProject {
        runtimeVersion = "2023.4.0.113";
        src = srcWithAssets;
      };
    in
    {
      packages.x86_64-linux.default = endless-void;
    };
}
