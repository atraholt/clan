{
  inputs = {
    clan-core.url = "git+https://git.clan.lol/clan/clan-core";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-locked-kernel.url = "github:nixos/nixpkgs/24188db7351021632efe39ae05f20caaf2481dc8";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-casks.url = "github:atahanyorganci/nix-casks/archive";
    nix-gaming.url = "github:fufexan/nix-gaming";
    catppuccin.url = "github:catppuccin/nix";

    #nixpkgs.follows = "clan-core/nixpkgs";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";
    clan-core.inputs.nix-darwin.follows = "nix-darwin";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-cachyos-kernel.inputs.nixpkgs.follows = "nixpkgs";
    nix-cachyos-kernel.inputs.flake-parts.follows = "flake-parts";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-casks.inputs.nixpkgs.follows = "nixpkgs";
    nix-casks.inputs.flake-parts.follows = "flake-parts";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";
    nix-gaming.inputs.flake-parts.follows = "flake-parts";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        imports = [
          ./clan.nix
          ./devshells.nix
          ./pkgs.nix
        ];
        perSystem =
          {
            system,
            pkgs,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              config.allowUnfreePredicate = _pkg: true;
              overlays = [ ];
            };
            clan.pkgs = pkgs;
          };
      };
}
