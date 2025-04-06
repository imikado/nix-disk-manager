{ lib, flutter, dart, zlib, gtk3, pkg-config, libtool, libGL, libX11, fetchurl }:

# Define the Flutter app package
flutter.buildFlutterApplication rec {
  pname = "nix_disk_manager";
  version = "1.4.0";

  src = fetchurl {

    url = "https://github.com/imikado/nix-disk-manager/archive/refs/tags/1.4.1.tar.gz";
    sha256 = "sha256-deca3a594e2a8dbd868677ae0e717c9de355c2e34908f69f834d5919fb9f4565;
  };

  autoPubspecLock = ./pubspec.lock;

  buildInputs = [ flutter dart zlib gtk3 pkg-config libtool libGL libX11 ];



}
