{...}: {
  virtualisation.docker = {
    enable = false;
    autoPrune.enable = true;
    enableOnBoot = true;
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true; # Create a `docker` alias for podman
  };
}
