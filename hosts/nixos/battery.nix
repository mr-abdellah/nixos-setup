{pkgs, ...}: let
  low_battery_notify = pkgs.writeShellApplication {
    name = "low_battery_notify";
    runtimeInputs = with pkgs; [libnotify bash];
    text = builtins.readFile ../../scripts/low_battery_notify.sh;
  };
in {
  systemd.user.services."low-battery-notif" = {
    description = "Low battery notification";
    serviceConfig = {
      Type = "oneshot";
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";
      ExecStart = "${low_battery_notify}/bin/low_battery_notify";
    };
  };

  systemd.user.timers."low-battery-notif" = {
    description = "Run low battery notification every 5 minutes";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };
}
