{...}: {
  # for journal not to blow up with time
  services.journald.extraConfig = "SystemMaxUse=50M";
}
