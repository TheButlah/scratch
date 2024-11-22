# Installing NixOS

To install NixOS, boot into any NixOS machine (or a NixOS livecd).

Then run the following, being sure to replace /dev/sda with the correct disk name:
```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:thebutlah/scratch#disko-install \
  -- -f github:thebutlah/scratch#vm --disk main /dev/sda
```

# Building a NixOS machine image

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  build github:thebutlah/scratch#nixosConfigurations.vm.config.system.build.diskoImagesScript
./result
```

