{...}: {
  services.logind = {
    settings.Login = {
      IdleAction = "ignore";
      HandleLidSwitch = "ignore";
    };
  };
}
