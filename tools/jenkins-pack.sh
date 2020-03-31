#!/bin/sh
#
# Pack helpers for Jenkins job
#

TARGET="$2"
BUILD_NO="$3"

VERSION="${TARGET}-$(cat vendor/bcm-template/.version)-${BUILD_NO}"
DST_DIR="$(pwd)/images"

gitinfo()
{
    local repo="$1"
    local name="$(basename $(git -C ${repo} remote -v | head -n 1 | awk '{ print $2 }'))"
    local commit=$(git -C ${repo} log --oneline -n 1 | awk '{print $1}')

    printf "%-34s : %s\n" "${name}" "${commit}"
}

gitarchive()
{
    local repo="$1"
    local name="$2"

    git -C ${repo} archive --format tar.gz -o ${DST_DIR}/${name}-${VERSION}.tar.gz HEAD
}

##
# Here we are are packing git commit hashes and archive of used repos.
#
pack_opensync_repos()
{
    local name="${DST_DIR}/opensync-repos-${VERSION}.list"

    echo "# Listing git repos"

    gitinfo .                     >  ${name}
    gitinfo platform/bcm          >> ${name}
    gitinfo vendor/bcm-template   >> ${name}
    cat ${name}

    echo "# Packing git repos"

    gitarchive .                     opensync-core
    gitarchive platform/bcm          opensync-platform-bcm
    gitarchive vendor/bcm-template   opensync-vendor-bcm
}

##
# Main
#
case $1 in
    opensync-repos)
        pack_opensync_repos
        ;;
    all)
        pack_opensync_repos
        ;;
esac
