{
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  user = {
    name = "media-stack";
    uid = 1013;
  };
  group = {
    name = "media-stack";
    gid = 1013;
  };
in {
  imports = [
    # (modulesPath + "/profiles/minimal.nix") # <-- do not! see: https://github.com/guyonvarch/playos/commit/a9669ca0470f1653ea6b7173eb250db2f39dd3f3
    # and https://github.com/NixOS/nixpkgs/issues/102137
    ./nspawn-image.nix
  ];

  boot.isContainer = true;

  documentation.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;

  # activate Nix Flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;
  networking = {
    firewall.enable = false;
    enableIPv6 = false;
  };

  environment.etc."resolv.conf".text = "nameserver 8.8.8.8\nnameserver 8.8.4.4";
  # required for systemd-nspawn https://github.com/NixOS/nixpkgs/issues/28833
  environment.etc."os-release".mode = "0444";

  # Generate with `openssl passwd -6 <password>`
  users.users.root.initialHashedPassword = "$6$nZjdJqbWrot/3qp1$gxUvzKo0o.6bjLmZqdifRXLDuilPFkzfl7rG7MNKH0HYY6R.d.lKIzo9V18vIOw6bPx46vUEbkWIWbgCPF2L11";

  users.groups."${group.name}" = {
    members = ["${user.name}"];
    gid = group.gid;
  };
  users.users."${user.name}" = {
    isNormalUser = true;
    uid = user.uid;
    group = "${group.name}";
    description = "${user.name}";
    extraGroups = ["systemd-journal" "render" "video"];
    shell = pkgs.bash;
    initialHashedPassword = "$6$nZjdJqbWrot/3qp1$gxUvzKo0o.6bjLmZqdifRXLDuilPFkzfl7rG7MNKH0HYY6R.d.lKIzo9V18vIOw6bPx46vUEbkWIWbgCPF2L11";
  };

  systemd.services.prowlarr = {
    description = "Prowlarr";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "${user.name}";
      Group = "${group.name}";
      ExecStart = "${pkgs.prowlarr}/bin/Prowlarr -nobrowser -data=/mediaconfs/prowlarr";
      Restart = "on-failure";
    };
  };

  systemd.services.jellyfin = {
    description = "Jellyfin";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/misc/jellyfin.nix
    serviceConfig = {
      Type = "simple";
      User = "${user.name}";
      Group = "${group.name}";
      WorkingDirectory = "/var/lib/jellyfin";
      ExecStart = "${pkgs.jellyfin}/bin/jellyfin --datadir '/var/lib/jellyfin' --cachedir '/tmp/jellyfin-cache'";
      Restart = "on-failure";
      SuccessExitStatus = ["0" "143"];
      TimeoutSec = 15;
    };
  };

  services = {
    transmission = {
      enable = true;
      user = "${user.name}";
      group = "${group.name}";
      performanceNetParameters = true;
      settings = {
        alt-speed-up = 10;
        alt-speed-down = 150;
        blocklist-enabled = true;
        blocklist-url = "https://github.com/sahsu/transmission-blocklist/releases/latest/download/blocklist.gz";
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
        peer-port = 51413;
        incomplete-dir = "/MEDIA/.downloading";
        download-dir = "/MEDIA/downloads";
        download-queue-enabled = true;
        download-queue-size = 3;
        idle-seeding-limit = 15;
        idle-seeding-enabled = true;
        ratio-limit-enabled = true;
        ratio-limit = 0.1;
        umask = 2;
      };
    };
    radarr = {
      enable = true;
      user = "${user.name}";
      group = "${group.name}";
      dataDir = "/mediaconfs/radarr";
    };
    sonarr = {
      enable = true;
      user = "${user.name}";
      group = "${group.name}";
      dataDir = "/mediaconfs/sonarr";
    };
    bazarr = {
      enable = true;
      user = "${user.name}";
      group = "${group.name}";
    };
  };

  system.stateVersion = "23.11";
}
