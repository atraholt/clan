{ ... }:
{

  zramSwap = {
    enable = true;
    algorithm = "zstd lz4 (type=huge)";
    memoryPercent = 100;
    priority = 100;
  };
}
