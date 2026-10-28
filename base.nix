{pkgs, ...}: {
  imports = [
    ./modules/systemd.nix
    ./modules/tailscale.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Africa/Algiers";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
  nix.settings.substituters = [
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  # Define a user account. The password is set at bootstrap time (hashed);
  # change it later with ‘passwd’ (mutableUsers = true by default).
  users.users.alauxui = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "podman"];
    shell = pkgs.zsh;
    initialHashedPassword = "/TG1Nhd9yU15cuOW2ou4tW4lNpwbMK1FmV2PgpebZHsQynyFwNWgygFl6DhIXvKj3sm7Jd1";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    unzip
    wget
    curl
    stow
    nix-search-cli
    starship
    television

    systemctl-tui

    btop

    fastfetch
    jq

    zoxide
    eza
    lsof
    go-task
    fzf
    fd
    bat
    killall
    nmap

    prefetch-npm-deps

    cloudflare-warp
  ];

  services.cloudflare-warp.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05";
}
