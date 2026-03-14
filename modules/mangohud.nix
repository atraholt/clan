{ ... }:
{
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      fps_limit = 60;
      preset = 0;
    };
  };
  catppuccin.mangohud.enable = true;
}
