#!/bin/sh
# SPDX-License-Identifier: LGPL-2.1-or-later

set -eux
cd "${0%/*}/../.."

# Show critical package versions
rpm -q subscription-manager-cockpit subscription-manager cockpit-bridge

. /usr/lib/os-release

# allow test to set up things on the machine
mkdir -p /root/.ssh
curl https://raw.githubusercontent.com/cockpit-project/bots/main/machine/identity.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# create user account for logging in
if ! id admin 2>/dev/null; then
    useradd -c Administrator -G wheel admin
    echo admin:foobar | chpasswd
fi

# set root's password
echo root:foobar | chpasswd

# avoid sudo lecture during tests
su -c 'echo foobar | sudo --stdin whoami' - admin

# disable core dumps, we rather investigate them upstream where test VMs are accessible
echo core > /proc/sys/kernel/core_pattern

# prepare the candlepin tarball run script where tests expect it
podman pull ghcr.io/candlepin/candlepin-unofficial:latest
cat <<EOF > /root/run-candlepin
#!/bin/sh
podman start candlepin
EOF
chmod 755 /root/run-candlepin

sh -x test/vm.install

# Run tests in the cockpit tasks container, as unprivileged user
CONTAINER="$(cat .cockpit-ci/container)"
exec podman \
    run \
        --rm \
        --shm-size=1024m \
        --security-opt=label=disable \
        --env='TEST_*' \
        --volume="${TMT_TEST_DATA}":/logs:rw,U --env=LOGS=/logs \
        --volume="$(pwd)":/source:rw,U --env=SOURCE=/source \
        --volume=/usr/lib/os-release:/run/host/usr/lib/os-release:ro \
        "${CONTAINER}" \
            sh /source/test/browser/run-test.sh "$@"
