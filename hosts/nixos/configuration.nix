{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./wayland.nix
    ./battery.nix
    ./boot.nix
    ./networking.nix
    ./nvidia.nix
    ./virtualization.nix
    ../../modules/claude-code.nix
    ../../modules/lid-screen.nix
  ];

  agents.claude-code.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "esc";
          };
        };
      };
    };
  };

  services.udisks2.enable = true;

  services.ratbagd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  programs.niri.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  environment.systemPackages = with pkgs; [
    heroic
    dxvk
    lutris
    gnupg
    (pass.withExtensions (exts: [
      exts.pass-otp
    ]))
    trash-cli
    mpv
    brave
    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    })
    libreoffice-fresh
    piper
  ];
}
