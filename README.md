# Installing NixOS

There are a few approaches to install NixOS.

## From an existing NixOS or NixOS LiveUSB
One approach is to boot the machine into NixOS, either from an existing install or from the NixOS liveusb.

Then run the following, being sure to replace /dev/sda with the correct disk name:
```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:thebutlah/scratch#disko-install \
  -- -f github:thebutlah/scratch#ryan-worldcoin-hil --disk main /dev/sda
```

## Remotely, via nixos-anywhere (Recommended)

nixos-anywhere lets you install NixOS over ssh, without requiring the target machine
to have any particular linux distro.

We will refer to two machines:
* target - the machine you want to install NixOS on
* builder - the machine you already have Nix installed on

### Requirements

The target requires:
* A linux distro installed (or a liveusb booted). The distro must support the
  `kexec` kernel feature - most machines support this out of the box.
* It must be x86_64-linux (TODO: add aarch64 support)
* It must have an account with sudo rights and the builder's ssh pub key added to that account
* It must be accessible over the internet from the builder. AKA either on the same LAN,
  or have its ports forwarded.
* It needs to be connected to Ethernet, NOT wifi. A wifi-only connection will cause the installation to fail partway through.

The builder requires:
* The same architecture as the target machine (x86_64-linux, for now).
* The Nix cli tool installed, with flakes configured. The 
  [determinate nix installer](https://zero-to-nix.com/concepts/nix-installer#using)
  is the recommended way to install the nix cli tool.
* You must be able to ssh into the target: try 
  ```bash
  ssh -i ~/path/to/ssh_priv_key username@target-ip-address
  ```

### Kicking off the install

On the *builder* machine (not the target!) run the following, being sure to replace the following:
* `config_name` - with the name of the NixOS configuration you are trying to install to the target. Example: `worldcoin-hil-munich-0`.
* `target_username` - the name of the username that has sudo rights on the target. Example: `ubuntu`.
* `target_hostname` - the hostname/ip address of the target machine. Example: `192.168.0.50`.
* `identity_file` - the path to the private key on the builder you will use to connect

```bash
nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/nixos-anywhere -- \
  --flake github:worldcoin/orb-software#<config_name> <target_username>@<target_hostname> -i <identity_file>
```
Example:
```bash
nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/nixos-anywhere -- \
  --flake github:worldcoin/orb-software#ryan-worldcoin-hil ubuntu@34.224.39.95 -i ~/ssh-key.pem
```

# Building a NixOS machine image

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  build github:thebutlah/scratch#nixosConfigurations.ryan-worldcoin-hil.config.system.build.diskoImagesScript
./result
```

## License

Licensed under the [MIT-0 License](LICENSE-MIT-0).
