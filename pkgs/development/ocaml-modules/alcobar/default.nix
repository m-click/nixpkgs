{
  afl-persistent,
  alcotest,
  buildDunePackage,
  calendar,
  cmdliner,
  fetchurl,
  fpath,
  lib,
  pprint,
  uucp,
  uunf,
}:

buildDunePackage (finalAttrs: {
  pname = "alcobar";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/samoht/alcobar/releases/download/v${finalAttrs.version}/alcobar-${finalAttrs.version}.tbz";
    hash = "sha256-V2UnvLrtf+XXkp7uFlrIpxg6+fZqwhCS/J7C3Nw+eVU=";
  };

  propagatedBuildInputs = [
    afl-persistent
    alcotest
    cmdliner
  ];

  checkInputs = [
    calendar
    fpath
    pprint
    uucp
    uunf
  ];
  doCheck = true;

  minimalOCamlVersion = "4.08";
  duneVersion = "3";

  meta = {
    description = "Crowbar with an Alcotest-compatible API";
    homepage = "https://github.com/samoht/alcobar";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vog ];
  };
})
