{pkgs, ...}: {
  imports = [
    ../../modules/home/base.nix
  ];

  systemd.user.services.swaybg = {
    Unit = {
      Description = "swaybg wallpaper";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i /home/alauxui/wallpaper.jpg -m fill";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww daemon and widgets";
      After = ["graphical-session.target" "iwd.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
      ExecStartPost = "${pkgs.eww}/bin/eww open-many left right bottom middle";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = "36.7538";
    longitude = "3.0588";
  };

  services.udiskie = {
    enable = true;
    automount = true;
    tray = "never";
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "none";
        width = 300;
        height = "(0, 300)";
        origin = "top-right";
        offset = "(20, 30)";
        scale = 0;
        notification_limit = 2;
        progress_bar = false;
        icon_corner_radius = 0;
        icon_corners = "all";
        indicate_hidden = true;
        transparency = 0;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 2;
        frame_color = "#ffffff";
        gap_size = 4;
        separator_color = "frame";
        sort = true;
        font = "FiraCode Nerd Font Mono 12";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "center";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        enable_recursive_icon_lookup = true;
        icon_theme = "Adwaita";
        icon_position = "off";
        min_icon_size = 32;
        max_icon_size = 128;
        sticky_history = true;
        history_length = 5;
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
        corners = "all";
        ignore_dbusclose = false;
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "close_all";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_current";
      };
      experimental = {
        per_monitor_dpi = false;
      };
      urgency_low = {
        background = "#000000";
        foreground = "#ffffff";
        timeout = 10;
      };
      urgency_normal = {
        background = "#000000";
        foreground = "#ffffff";
        timeout = 10;
      };
      urgency_critical = {
        background = "#000000";
        foreground = "#ffffff";
        timeout = 10;
      };
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  home.activation.stowDotfiles = let
    inherit (pkgs) stow;
    dotfilesDir = "/home/alauxui/nixos/dotfiles";
    packages = "niri waybar kitty hypr television zsh direnv rofi";
  in {
    after = ["writeBoundary"];
    before = [];
    data = ''
      ${stow}/bin/stow --restow -d ${dotfilesDir} -t $HOME ${packages} 2>/dev/null || true
    '';
  };
}
