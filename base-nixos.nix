{ pkgs, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # use the latest Linux kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.grub.device = "nodev";
    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
    # binfmt.emulatedSystems = [ "x86_64-linux" ];
  };

  # Define a user account. Don't forget to set a password with ‘pas.
  users.users.worldcoin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
    initialPassword = "foobar";
  };

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.n.
    curl
    parted
    usbutils
    wget
  ];

  # Do not change this
  system.stateVersion = lib.mkForce "24.05";
}
