{ inputs, pkgs, modulesPath, lib, system, username, hostname, ... }: {
  imports = [
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
	./hardware-configuration.nix
  ];

  nix = {
    package = pkgs.nix;
    channel.enable = false;
    nixPath = lib.mkForce [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      "experimental-features" = [ "nix-command" "flakes" "repl-flake" ];
      "max-jobs" = "auto";
      trusted-users = [
        "root"
        "@admin"
        username
      ];
    };
  };
  nixpkgs.flake = {
    setFlakeRegistry = true;
    setNixPath = true;
  };

  # use the latest Linux kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # BEGIN recommendations from disko:
    # https://github.com/nix-community/disko/blob/abc8baff/docs/quickstart.md
    #loader.systemd-boot.enable = true;
    #loader.efi.canTouchEfiVariables = true;
    loader.grub.enable = true;
    loader.grub.efiSupport = true;
    loader.grub.efiInstallAsRemovable = true;
    # loader.grub.device is set by disko automatically
    # END disko

    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };

  # Define a user account. Don't forget to set a password with ‘pas.
  users.groups = {
    plugdev = { };
  };
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "dialout" # serial access
      "networkmanager" # wifi control
      "plugdev" # usb access
      "wheel" # sudo powers
    ]; # Enable ‘sudo’ for the user.
    # initialPassword = "foobar";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLmHbuCMFpOKYvzMOpTOF+iMX9rrY6Y0naarcbWUV8G ryan@ryan-laptop.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoVo3BKge5tQuYpDuWKJaypdpfUuw4cq3/BYRFNovtj ryan.butler@Ryan-Butler.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOhklnZHdjM0VD82Z1naZaoeM3Lr9dbrsM0r+J9sHqN alex@hq-small"
    ];
  };
  users.mutableUsers = false;

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "${username}";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # USB stuff
  services.udev = {
    enable = true;
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"
    '';
  };

  services.resolved = {
    enable = true;
    # set to "false" if giving you trouble
    dnsovertls = "opportunistic";
    # dnsovertls = "false";
  };

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.n.
    curl
    parted
    usbutils
    wget
    git
  ] ++
  [
    inputs.disko.packages.${system}.disko-install
    inputs.disko.packages.${system}.disko
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.hostName = hostname;

  # Set your time zone.
  time.timeZone = "America/New_York";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # The config was written with 24.05 in mind. Don't change it unless you have
  # reviewed the new settings options.
  system.stateVersion = lib.mkForce "24.05";
}
