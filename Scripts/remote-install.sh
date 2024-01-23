#!/usr/bin/env bash

echo "Creating temporary directory"
TEMP_DIR=$(mktemp -d)

# Configure cleanup
function cleanup {
    echo
    echo "Removing temporary directory $TEMP_DIR"
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "Cloning FileOrganiser"
git clone https://github.com/henrik-dmg/FileOrganiser.git $TEMP_DIR

echo "Building FileOrganiser"
swift build -c release --package-path $TEMP_DIR

echo "Making file-organiser executable"
chmod +x "$TEMP_DIR/.build/release/file-organiser"

echo "Copying file-organiser to /usr/local/bin (may require sudo)"
if [ ! -f /usr/local/bin/file-organiser ]; then
    sudo cp "$TEMP_DIR/.build/release/file-organiser" /usr/local/bin/file-organiser
else
    read -p "File with same name exists. Do you want to overwrite? (Y or y) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm /usr/local/bin/file-organiser
        sudo cp "$TEMP_DIR/.build/release/file-organiser" /usr/local/bin/file-organiser
    else
        echo "Aborting installation"
        exit 1
    fi
fi
