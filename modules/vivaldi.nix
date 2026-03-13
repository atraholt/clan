{ pkgs, ... }:
{
  programs.vivaldi = {
    enable = true;
    package = pkgs.vivaldi;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };
}
