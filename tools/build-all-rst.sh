#!/bin/bash -e

mkdir -p publish-docs

# Set this to a sensible value if not set by OpenStack CI.
if [ -z "$ZUUL_REFNAME" ] ; then
    ZUUL_REFNAME="master"
fi

# This marker is needed for infra publishing.
# Note for stable branches, this needs to be the top of each manual.
MARKER_TEXT="Project: $ZUUL_PROJECT Ref: $ZUUL_REFNAME Build: $ZUUL_UUID Revision: $ZUUL_NEWREV"

LINKCHECK=""
PDF_OPTION=""
while [[ $# > 0 ]] ; do
    option="$1"
    case $option in
        --linkcheck)
            LINKCHECK="--linkcheck"
            ;;
        --pdf)
            PDF_OPTION="--pdf"
            ;;
    esac
    shift
done

# PDF targets for Install guides are dealt in build-install-guides-rst.sh
PDF_TARGETS=( 'arch-design'\
              'ha-guide' \
              'image-guide' \
              'install-guide')

for guide in arch-design contributor-guide \
    ha-guide ha-guide-draft image-guide install-guide; do
    if [[ ${PDF_TARGETS[*]} =~ $guide ]]; then
        tools/build-rst.sh doc/$guide --build build \
            --target $guide $LINKCHECK $PDF_OPTION
    else
        tools/build-rst.sh doc/$guide --build build \
            --target $guide $LINKCHECK
    fi
done

# For master, just mark the root
if [ "$ZUUL_REFNAME" = "master" ] ; then
    echo $MARKER_TEXT > publish-docs/.root-marker
fi
