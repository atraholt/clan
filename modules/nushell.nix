{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    plugins = with pkgs; [
      nushell-plugin-dbus
      nushell-plugin-net
    ];
  };
}
