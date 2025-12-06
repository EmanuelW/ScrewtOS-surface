#!/usr/bin/bash

set -eoux pipefail

echo "::group::Executing install-kernel"
trap 'echo "::endgroup::"' EXIT

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs

pkgs=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
    kernel-modules-akmods
    kernel-devel
    kernel-devel-matched
    kernel-tools
    kernel-tools-libs
    kernel-common
)

PKG_PAT=()
for pkg in "${pkgs[@]}"; do
    # FIXME: assumes the kernel starts with version 6
    PKG_PAT+=("/rpms/kernel/${pkg}-6"*)
done

# Temporarily remove the version lock on kernel packages to allow install of Bazzite kernel
# TODO: Figure out why there are several version we lock here:
# + dnf5 versionlock add kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-modules-akmods kernel-devel kernel-devel-matched kernel-tools kernel-tools-libs kernel-common
# Updating and loading repositories:
# Repositories loaded.
# Adding versionlock on "kernel = 6.17.7-300.fc43".
# Adding versionlock on "kernel-core = 6.17.7-300.fc43".
# Adding versionlock on "kernel-modules = 6.17.7-300.fc43".
# Adding versionlock on "kernel-modules-core = 6.17.7-300.fc43".
# Adding versionlock on "kernel-modules-extra = 6.17.7-300.fc43".
# No package found for "kernel-modules-akmods".
# Adding versionlock on "kernel-devel = 6.17.7-300.fc43".
# Adding versionlock on "kernel-devel-matched = 6.17.7-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.1-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.4-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.5-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.6-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.7-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.8-300.fc43".
# Adding versionlock on "kernel-tools = 6.17.9-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.1-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.4-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.5-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.6-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.7-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.8-300.fc43".
# Adding versionlock on "kernel-tools-libs = 6.17.9-300.fc43".

dnf5 versionlock delete ${pkgs[@]}

dnf5 -y install ${PKG_PAT[@]}

dnf5 versionlock add ${pkgs[@]}

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd
