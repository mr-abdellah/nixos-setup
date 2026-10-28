{...}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 10;
    timeout = 1;
  };

  boot.blacklistedKernelModules = [
    "intel_rapl_msr"
    "intel_rapl_common"
    "snd_seq_dummy"
    "joydev"
    "mousedev"
  ];

  boot.kernelModules = ["kvm-amd"];
  boot.kernelParams = [
    # "quiet" # disables systemd loadscreen for faster boot
    # "acpi_enforce_resources=lax" # silence USBC000 ACPI resource-claim error (firmware quirk)
  ];

  boot.enableContainers = true;
}
