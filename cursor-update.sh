#!/bin/bash -ex

BINDIR=$HOME/bin
TEMPDIR=/tmp/cursor

# Get the latest version from the download page
FETCH_STABLE=$(curl --silent 'https://cursor.com/download')
# Extract the latest version and download URL from the HTML
APPIMAGE_URL=$(echo $FETCH_STABLE | grep -o 'https://downloads\.cursor\.com/production/[^"]*linux/x64/Cursor-[^"]*\.AppImage' | head -1)
APPIMAGE_VERSION=$(echo $APPIMAGE_URL | grep -o 'Cursor-[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

function writeConfig() {
  echo "CURRENT_VERSION=$APPIMAGE_VERSION" >$HOME/.config/Cursor/LastVersion
  echo "USE_AS_SHIPPED=$USE_AS_SHIPPED" >>$HOME/.config/Cursor/LastVersion
}
if [ -f $HOME/.config/Cursor/LastVersion ]; then
  . $HOME/.config/Cursor/LastVersion
else
  USE_AS_SHIPPED=0
  CURRENT_VERSION=0
fi

# Check if the first argument is --useAsShipped
case "$1" in
--useAsShipped)
  USE_AS_SHIPPED=1
  ;;
--useAsShipped=false)
  USE_AS_SHIPPED=0
  ;;
*)
  USE_AS_SHIPPED=${USE_AS_SHIPPED:-0}
  ;;
esac

if [ "$CURRENT_VERSION" == "$APPIMAGE_VERSION" ]; then
  writeConfig
  notify-send "Updating Cursor" "Already up to date"
  exit 0
fi
notify-send "Updating Cursor" "Downloading latest version"

mkdir -p $TEMPDIR
pushd $TEMPDIR

curl $APPIMAGE_URL --output $TEMPDIR/cursor.AppImage.original
chmod +x $TEMPDIR/cursor.AppImage.original

if [ "$USE_AS_SHIPPED" = "1" ]; then
  # If --useAsShipped is provided, skip the extraction and modification
  mkdir -p $BINDIR
  cp $TEMPDIR/cursor.AppImage.original $BINDIR/cursor
  chmod +x $BINDIR/cursor

  # Clean up and exit
  popd
  writeConfig
  rm -rf $TEMPDIR
  notify-send "Updating Cursor" "Updated to version $APPIMAGE_VERSION (as shipped)"
  exit 0
fi

# Extract the AppImage
$TEMPDIR/cursor.AppImage.original --appimage-extract
rm $TEMPDIR/cursor.AppImage.original

# Fix it by replacing all occurrences of ",minHeight" with ",frame:false,minHeight"
TARGET_FILE="squashfs-root/usr/share/cursor/resources/app/out/main.js"
sed -i 's/,minHeight/,frame:false,minHeight/g' "$TARGET_FILE"

# Download latest appimagetool
curl -L -o $TEMPDIR/appimagetool-x86_64.AppImage https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x $TEMPDIR/appimagetool-x86_64.AppImage

# Repackage the AppImage using appimagetool
rm -f $BINDIR/cursor
$TEMPDIR/appimagetool-x86_64.AppImage squashfs-root/ $BINDIR/cursor
chmod +x $BINDIR/cursor

popd

writeConfig
# Cleaning Up
rm -rf $TEMPDIR
