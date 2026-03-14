{ pkgs, ... }:
{
  imports = [
    ../fish.nix
  ];
  environment.systemPackages = with pkgs; [
    btop
    #nushell
  ];
}
