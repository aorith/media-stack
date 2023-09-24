#!/usr/bin/env bash
cd "$(dirname -- "$0")" || exit 1
set -euo pipefail

[[ ! -e /run/.containerenv ]] || {
    echo "Run outside of a container."
    exit 1
}

[[ "$UID" == "0" ]] || {
    echo "Run as root."
    exit 1
}

# https://bugzilla.redhat.com/show_bug.cgi?id=1900888
# https://relativkreativ.at/articles/how-to-compile-a-selinux-policy-package

# Build the SELinux modules from the te file
rm -f ./*.mod
rm -f ./*.pp

checkmodule -M -m ./machines-policy.te -o ./machines-policy.mod
semodule_package -m ./machines-policy.mod -o ./machines-policy.pp

checkmodule -M -m ./machines-login.te -o ./machines-login.mod
semodule_package -m ./machines-login.mod -o ./machines-login.pp

checkmodule -M -m ./machinectl-import.te -o ./machinectl-import.mod
semodule_package -m ./machinectl-import.mod -o ./machinectl-import.pp

# Install the modules
semodule -i ./machines-policy.pp
semodule -i ./machines-login.pp
semodule -i ./machinectl-import.pp

# Enable daemons_use_tty to be able to login using machinectl login 
setsebool -P daemons_use_tty 1
