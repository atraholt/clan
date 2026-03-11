{ self, pkgs, ... }:
let
  cask = self.inputs.nix-casks.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ ./casks.nix ];
  environment.casks = [
    cask.ungoogled-chromium
    cask.signal
    cask.ghostty
    cask.alfred
    cask.fork
    cask.galaxybudsclient
    cask.signal
    cask.tailscale-app
    cask.vivaldi
    cask.visual-studio-code
  ];
}
