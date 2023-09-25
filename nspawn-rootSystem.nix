{
  config,
  pkgs,
  ...
}: let
  _symlinks = [
    {
      object = config.system.build.toplevel;
      symlink = "/nix/var/nix/profiles/system";
    }
  ];

  _files = [
  ];

  _files_no_symlink = [
    {
      # Required by machinectl
      source = config.system.build.toplevel + "/etc/os-release";
      target = "/etc/os-release";
    }
  ];
in {
  boot.postBootCommands = ''
    echo "Hi there!
  '';

  system.build.rootSystem = pkgs.stdenv.mkDerivation {
    name = "nixos-root";
    builder = ./make-system-root.sh;

    sources = map (x: x.source) _files;
    targets = map (x: x.target) _files;

    sources_nl = map (x: x.source) _files_no_symlink;
    targets_nl = map (x: x.target) _files_no_symlink;

    symlinks = map (x: x.symlink) _symlinks;
    objects = map (x: x.object) _symlinks;
  };
}
