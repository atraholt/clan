# Forked from: https://github.com/drakon64/nixos-xivlauncher-rb
# MIT License
#
# Copyright (c) 2018 Francesco Gazzetta
{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  sdl3,
  libsecret,
  glib,
  gnutls,
  aria2,
  steam,
  gst_all_1,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  writeScript,
  useSteamRun ? true,
  useGameMode ? false,
  nvngxPath ? "",
  wine-tkg,
  dxvk-w64,
}:
let
  tag = "1.4.0.1";
in
buildDotnetModule rec {
  pname = "xivlauncher-rb";
  version = tag;

  src = fetchFromGitHub {
    owner = "rankynbass";
    repo = "XIVLauncher.Core";
    rev = "rb-v${tag}";
    hash = "sha256-yuZ7sHEWN7v+T/rQwoZiX4RRZicYMjEU7gkQzUDrzTk";
    fetchSubmodules = true;
  };
  # update with:
  # nix-build -A xivlauncher-rb.updateScript
  # then run the resulting derivation i.e. /nix/store/XXXX-update-xivlauncher-rb
  passthru.updateScript = writeScript "update-xivlauncher-rb" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-update
    nix-update ${pname} --flake --version-regex '(?:v|rb-v|)(.*)(?:-.*|\+.*|)' --version=unstable
  '';

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
  # update with:
  # nix-build -A xivlauncher-rb.passthru.fetch-deps
  # then run the resulting derivation i.e. /nix/store/XXXX-xivlauncher-rb-1.4.0.1-fetch-deps
  projectFile = "src/XIVLauncher.Core/XIVLauncher.Core.csproj";
  nugetDeps = ./deps.json;

  # please do not unpin these even if they match the defaults, xivlauncher is sensitive to .NET versions
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  dotnetFlags = [
    "-p:BuildHash=${tag}"
    "-p:PublishSingleFile=false"
  ];

  postPatch = ''
    substituteInPlace lib/FFXIVQuickLauncher/src/XIVLauncher.Common/Game/Patch/Acquisition/Aria/AriaPatchAcquisition.cs  \
      --replace-fail 'ariaPath = "aria2c"' 'ariaPath = "${aria2}/bin/aria2c"'
  '';

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp src/XIVLauncher.Core/Resources/logo.png $out/share/pixmaps/xivlauncher.png
  '';

  postFixup =
    lib.optionalString useSteamRun (
      let
        steam-run =
          (steam.override {
            extraPkgs =
              pkgs:
              [
                pkgs.libunwind
                pkgs.zstd
              ]
              ++ lib.optional useGameMode pkgs.gamemode;
            # TODO: figure out a long-term solution for non useSteamRun users
            extraLibraries = pkgs: lib.optional useGameMode pkgs.gamemode;
            extraProfile = ''
              unset TZ
            '';
          }).run;
      in
      ''
        substituteInPlace $out/bin/XIVLauncher.Core \
          --replace 'exec' 'exec ${steam-run}/bin/steam-run'
      ''
    )
    + ''
      wrapProgram $out/bin/XIVLauncher.Core --prefix LD_LIBRARY_PATH ":" ${lib.makeLibraryPath runtimeDeps} \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0" \
    ''
    + lib.optionalString (nvngxPath != "") ''
      --prefix XL_NVNGXPATH ":" ${nvngxPath}) \
    ''
    + ''
      --run '
      _dxvk="$HOME/.xlcore/compatibilitytool/dxvk/dxvk-gplasync-nix/x64"
      mkdir -p "$(dirname "$_dxvk")"
      rsync -auv "${dxvk-w64}/bin/" "$_dxvk"
      chmod -R u+w $_dxvk
      _xivwine="$HOME/.xlcore/compatibilitytool/wine/wine-tkg-nixos"
      mkdir -p "$(dirname "$_xivwine")"
      if [ "$(readlink "$_xivwine" 2>/dev/null)" != "${wine-tkg}" ]; then
          ln -sfn "${wine-tkg}" "$_xivwine"
      fi
      '
      # the reference to aria2 gets mangled as UTF-16LE and isn't detectable by nix: https://github.com/NixOS/nixpkgs/issues/220065
      mkdir -p $out/nix-support
      echo ${aria2} >> $out/nix-support/depends
    '';

  executables = [ "XIVLauncher.Core" ];

  runtimeDeps = [
    sdl3
    libsecret
    glib
    gnutls
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "xivlauncher-rb";
      exec = "XIVLauncher.Core";
      icon = "xivlauncher";
      desktopName = "XIVLauncher-RB";
      comment = meta.description;
      categories = [ "Game" ];
      startupWMClass = "XIVLauncher.Core";
    })
  ];

  meta = with lib; {
    description = "Custom launcher for FFXIV";
    changelog = "https://github.com/rankynbass/XIVLauncher.Core/releases/tag/rb-v${version}";
    homepage = "https://github.com/rankynbass/XIVLauncher.Core";
    license = licenses.gpl3;
    #maintainers = with maintainers; [ sersorrel witchof0x20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "XIVLauncher.Core";
  };
}
