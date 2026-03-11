{ ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
    config.nvidia.acceptLicense = true;
    hostPlatform = {
      #gcc.arch = "x86-64-v3";
      system = "x86_64-linux";
    };
  };
}
