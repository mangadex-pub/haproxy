set -euo pipefail

function set_build_vars_dev() {
    export HAPROXY_GITREPO="https://git.haproxy.org/?p=haproxy.git"
    export HAPROXY_VERSION="3.2-dev"
    echo "Import build vars for dev profile ($HAPROXY_VERSION)"

    # https://git.haproxy.org/?p=haproxy.git;a=commit;h=8235a24782e528b9bf8ca9dd69c0a147556dfcb5
    export HAPROXY_GITREF="8235a24782e528b9bf8ca9dd69c0a147556dfcb5"

    export BUILD_PATCHES_DIR="patches-dev"
    export HAPROXY_LIBASAN="false"
    export HAPROXY_LIBUBSAN="false"
    export HAPROXY_OPTIMIZATION="-Og"

}

function set_build_vars_stable() {
    export HAPROXY_GITREPO="https://git.haproxy.org/?p=haproxy-3.1.git"
    export HAPROXY_VERSION="3.1-stable"
    echo "Import build vars for stable profile ($HAPROXY_VERSION)"

    # https://git.haproxy.org/?p=haproxy-3.1.git;a=commit;h=v3.1.3
    export HAPROXY_GITREF="v3.1.3"

    export BUILD_PATCHES_DIR="patches-stable"
    export HAPROXY_LIBASAN="false"
    export HAPROXY_LIBUBSAN="false"
    export HAPROXY_OPTIMIZATION="-O2"
}
