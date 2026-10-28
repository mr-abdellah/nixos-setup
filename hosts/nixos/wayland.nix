{
  pkgs,
  config,
  lib,
  ...
}: let
  niri_toggle_window = pkgs.writeShellApplication {
    name = "niri_toggle_window";
    runtimeInputs = with pkgs; [niri];
    text = builtins.readFile ../../scripts/niri_toggle_window.sh;
  };

  commonPkgs = with pkgs; [
    bibata-cursors
    libnotify
    brightnessctl
    kitty
    impala
    bluetui
    wl-clipboard
  ];

  niriPackages = with pkgs; [
    xwayland-satellite
    xdg-desktop-portal-gnome
    niri_toggle_window
    swaybg
    eww
    jq
    waybar
    rofi
  ];

  hyprlandPackages = with pkgs; [
    hyprshot
  ];

  isNiri = config.programs.niri.enable;
  isHyprland = config.programs.hyprland.enable;
in
  lib.mkIf (isNiri || isHyprland) {
    environment.systemPackages =
      commonPkgs
      ++ lib.optionals isNiri niriPackages
      ++ lib.optionals isHyprland hyprlandPackages;

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      ipafont
      geist-font
    ];

    programs.hyprlock = {
      enable = true;
    };

    services.displayManager.ly = {
      enable = true;
      settings = {
        hide_version_string = true;
        hide_borders = true;
        hide_key_hints = true;
        hide_keyboard_locks = true;
      };
    };

    # hint Electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  }
