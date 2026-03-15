{
  config,
  pkgs,
  lib,
  ...
}:
{
  catppuccin.vscode.profiles.default.enable = true;
  home.file.".vscode-server/extensions".source = config.home.file.".vscode/extensions".source;
  programs.vscode.enable = true;
  programs.vscode.mutableExtensionsDir = false;
  programs.vscode.profiles.default.extensions =
    with pkgs.vsode-extensions;
    [
      eamodio.gitlens
      editorconfig.editorconfig
      mkhl.direnv
      shardulm94.trailing-spaces
      jnoortheen.nix-ide
      sumneko.lua
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.isx86_64 || pkgs.stdenv.hostPlatform.isDarwin) [
      (pkgs.vscode-extensions.ms-python.python.override {
        pythonUseFixed = true;
      })
    ];
  programs.vscode.profiles.default.userSettings =

    {
      "update.mode" = "manual";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;

      "telemetry.telemetryLevel" = "off";
      "workbench.enableExperiments" = false;
      "workbench.settings.enableNaturalLanguageSearch" = false;

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = lib.getExe pkgs.nil;
      "nix.serverSettings".nil.formatting.command = [
        (lib.getExe pkgs.alejandra)
      ];
      "nix.serverSettings".nil.nix.flake.autoArchive = true;

      "workbench.colorTheme" = "Catppuccin Mocha";

      "editor.formatOnSave" = true;
      # Primarily for ESLint
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
      };

      "editor.lineNumbers" = "relative";
      "editor.renderFinalNewline" = "off";
      "files.insertFinalNewline" = true;
      "diffEditor.diffAlgorithm" = "advanced";
      "diffEditor.ignoreTrimWhitespace" = false;
      "trailing-spaces.trimOnSave" = true;
      "trailing-spaces.highlightCurrentLine" = false;

      "search.useGlobalIgnoreFiles" = true;
      "files.exclude" = {
        "**/.direnv" = true;
        "**/.jj" = true;
      };

      # Don't use VS Code's 3 way merge editor
      "git.mergeEditor" = false;

      # Don't use GitLens to edit git rebase commands
      "workbench.editorAssociations" = {
        "git-rebase-todo" = "default";
      };

      # Don't warn when Git is disabled due to conflicts with jjk
      "gitlens.advanced.messages" = {
        "suppressGitDisabledWarning" = true;
        "suppressGitMissingWarning" = true;
      };

      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;

      "terminal.integrated.scrollback" = 1000000;
      "terminal.integrated.stickyScroll.enabled" = false;

      "files.associations" = {
        "flake.lock" = "json";
        "yarn.lock" = "yaml";
        ".env.*" = "properties";
      };

      # WORKAROUND: VS Code crashes when running under Wayland
      # https://github.com/NixOS/nixpkgs/issues/246509
      #"window.titleBarStyle" = "custom";

      # Disable Copilot
      "terminal.integrated.initialHint" = false;
    };
  programs.git.settings.core.editor = lib.getExe (
    pkgs.writeShellApplication {
      name = "use-vscode-sometimes";
      text = ''
        if [[ $TERM_PROGRAM = "vscode" ]]; then
          code --wait "$@"
        else
          vim "$@"
        fi
      '';
    }
  );
}
