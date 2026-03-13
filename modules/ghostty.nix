{ ... }:
{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
  };
  catppuccin.ghostty.enable = true;
}
