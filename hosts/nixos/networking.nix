{...}: {
  networking.hostName = "nixos";

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  environment.etc.hosts.enable = false;

  services.dnsmasq = {
    enable = true;
    settings.server = ["1.1.1.1"];
  };

  networking.nameservers = ["127.0.0.1"];
}
