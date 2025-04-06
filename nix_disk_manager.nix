{ lib, flutter, dart, zlib, gtk3, pkg-config, libtool, libGL, libX11, fetchurl }:

# Define the Flutter app package
flutter.buildFlutterApplication rec {
  pname = "nix_disk_manager";
  version = "1.1.2";

  src = fetchurl {

    url = "https://codeberg.org/imikado/nix-disk-manager/archive/1.3.1.tar.gz";
    sha256 = "sha256-53d3f4094afe7b565614510e7e6d3055577cadc7675260d61bd0b1be67016da0;
  };

  autoPubspecLock = ./pubspec.lock;

  buildInputs = [ flutter dart zlib gtk3 pkg-config libtool libGL libX11 ];



}
