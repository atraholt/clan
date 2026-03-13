{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    nushell
  ];
}
