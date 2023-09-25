# Modified from: https://github.com/NixOS/nixpkgs/blob/5d20a2b99a586c6611b30b12a684df96f8f95c1c/nixos/lib/make-system-tarball.sh#L1

source $stdenv/setup

sources_=($sources)
targets_=($targets)

sources_nl_=($sources_nl)
targets_nl_=($targets_nl)

objects=($objects)
symlinks=($symlinks)

# Remove the initial slash from a path, since genisofs likes it that way.
stripSlash() {
    res="$1"
    if test "${res:0:1}" = /; then res=${res:1}; fi
}

# Add the individual files.
for ((i = 0; i < ${#targets_[@]}; i++)); do
    stripSlash "${targets_[$i]}"
    mkdir -p "$(dirname "$res")"
    cp -a "${sources_[$i]}" "$res"
done

# Add the individual files (without following symlinks).
for ((i = 0; i < ${#targets_nl_[@]}; i++)); do
    stripSlash "${targets_nl_[$i]}"
    mkdir -p "$(dirname "$res")"
    cp --dereference "${sources_nl_[$i]}" "$res"
done

# Add symlinks to the top-level store objects.
for ((n = 0; n < ${#objects[*]}; n++)); do
    object=${objects[$n]}
    symlink=${symlinks[$n]}
    if test "$symlink" != "none"; then
        mkdir -p "$(dirname -- ./"$symlink")"
        ln -s "$object" ./"$symlink"
    fi
done

mkdir -p proc sys dev sbin
ln -sf /nix/var/nix/profiles/system/init sbin/init

mkdir -p "$out"/root
cp -r --no-dereference ./* "$out"/root/
rm -f "$out"/root/env-vars
