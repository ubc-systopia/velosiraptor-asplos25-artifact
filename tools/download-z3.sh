#! /bin/bash -eu

####################################################################################################
# Script to download the Z3 binary
####################################################################################################

# this is the Z3 Version that we are using.
Z3_VERSION="4.10.2"

# We currently don't support MacOS
if [ `uname` == "Darwin" ]; then
    echo "MacOS is currently not suppored for this artifact"
    exit -1
elif [ `uname` == "Linux" ]; then
    if [[ $(uname -m) == 'x86_64' ]]; then
        FILENAME="z3-$Z3_VERSION-x64-glibc-2.31"
    else
        echo "Architecture not supported: $(uname -m)"
        exit -1
    fi
else
    echo "Unsupported OS $(uname)"
    exit -1
fi

URL="https://github.com/Z3Prover/z3/releases/download/z3-$Z3_VERSION/$FILENAME.zip"

echo "Downloading: $URL"
wget "$URL"
unzip "$FILENAME.zip"

# install the binary
cp "$FILENAME/bin/z3" .

# Clean up the downloaded files
rm -r "$FILENAME"
rm "$FILENAME.zip"