{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        # pkgs.asdf-vm
        # pkgs.awscli2
        # pkgs.bat
        # pkgs.cfssl
        # pkgs.delta
        # pkgs.difftastic
        # pkgs.dyff
        # pkgs.eksctl
        # pkgs.evans
        # pkgs.eza
        # pkgs.fd
        # pkgs.fzf
        # pkgs.gh
        # pkgs.gnupg
        # pkgs.go
        # pkgs.go-jsonnet
        # pkgs.go-task
        # pkgs.golangci-lint
        # pkgs.goreleaser
        # pkgs.gradle
        # pkgs.granted
        # pkgs.graphviz
        # pkgs.grpcurl
        # pkgs.hatch
        # pkgs.htop
        # pkgs.httpie
        # pkgs.istioctl
        # pkgs.jq
        # pkgs.k9s
        # pkgs.krew
        # pkgs.kubebuilder
        # pkgs.kubectl
        # pkgs.kubernetes-helm
        # pkgs.kustomize
        # pkgs.neovim
        # pkgs.parallel
        # pkgs.pipenv
        # pkgs.pipx
        # pkgs.podman
        # pkgs.podman-compose
        # pkgs.pre-commit
        # pkgs.ripgrep
        # pkgs.shellcheck
        # pkgs.silver-searcher
        # pkgs.skopeo
        # pkgs.sonobuoy
        # pkgs.steampipe
        # pkgs.tree-sitter
        # pkgs.trivy
        # pkgs.vcluster
        # pkgs.velero
        # pkgs.xz
        # pkgs.yq-go
        # pkgs.zoxide
      ];

      services.skhd.enable = true;
      services.skhd.package = pkgs.skhd;
      services.skhd.skhdConfig = builtins.readFile ./skhdrc;

      services.yabai.enable = true;
      services.yabai.package = pkgs.yabai;
      services.yabai.extraConfig = builtins.readFile ./yabairc;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Touch ID sudo
      security.pam.enableSudoTouchIdAuth = true;

      # System defaults
      system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;
      system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
      system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
      system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
      system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
      system.defaults.dock.autohide = true;
      system.defaults.dock.mru-spaces = false;
      system.defaults.dock.show-recents = false;
      system.defaults.finder.AppleShowAllExtensions = true;
      system.defaults.finder.AppleShowAllFiles = true;
      system.defaults.finder.ShowPathbar = true;
      system.defaults.finder.ShowStatusBar = true;
      system.defaults.finder._FXShowPosixPathInTitle = true;
      system.defaults.menuExtraClock.Show24Hour = true;
      system.defaults.menuExtraClock.ShowSeconds = true;
      system.defaults.trackpad.Clicking = true;
      system.defaults.trackpad.TrackpadThreeFingerDrag = true;

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake ".#base"
    darwinConfigurations."base" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."base".pkgs;
  };
}
