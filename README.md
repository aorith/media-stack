# Media Stack

> Media Stack inside of a systemd-nspawn NixOs Container

A modified version of [https://github.com/tfc/nspawn-nixos](https://github.com/tfc/nspawn-nixos) that uses a plain
directory instead of tarballs to generate the rootfs of the container.

This configuration with a tarball (see "tarball" branch): ~700 MB  
With plain FS: 17 MB (of course everything else is in the nix store)

```sh
$ du -sh result/
12K     result/
$ sudo du -sh /var/lib/machines/media-stack
17M     /var/lib/machines/media-stack
```

- Only works if the container runs in the same machine that builds it.
- Works on non NixOS linux machines, only nix is required.
- Containers must bind the local `/nix/store`, see [media-stack.nspawn](./media-stack.nspawn).
- Building and importing is faster.

To create a new container:

- Clone this repository
- Edit [configuration.nix](./configuration.nix)
- Edit [Makefile](./Makefile) (change container name)
- Create a `*.nspawn` file with the container name (see [media-stack.nspawn](./media-stack.nspawn))
