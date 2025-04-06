{ lib, flutter, dart, zlib, gtk3, pkg-config, libtool, libGL, libX11, fetchurl }:

# Define the Flutter app package
flutter.buildFlutterApplication rec {
  pname = "nix_disk_manager";
  version = "1.4.0";

  src = fetchurl {

    url = "https://github.com/imikado/nix-disk-manager/archive/refs/tags/1.4.0.tar.gz";
    sha256 = "sha256-2fdef9e87988c49f6332d8020eb3f5492e3a47c2f3fac52a167cd3600d7f7887;
  };

  autoPubspecLock = ./pubspec.lock;

  buildInputs = [ flutter dart zlib gtk3 pkg-config libtool libGL libX11 ];



}
