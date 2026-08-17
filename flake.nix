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

      ev = gamemaker-flake.packages.x86_64-linux.buildGameMakerProject {
        src = srcWithAssets;
        runtimeVersion = "2023.4.0.113";
      };
      ev-no-vs-assets-very-cursed = gamemaker-flake.packages.x86_64-linux.buildGameMakerProject {
        src = ./.;
        runtimeVersion = "2023.4.0.113";
        configuration = "NoVoidStrangerGroups";
      };
    in
    {
      packages.x86_64-linux.default = ev;
      packages.x86_64-linux.no-vs-assets-very-cursed = ev-no-vs-assets-very-cursed;
    };
}
