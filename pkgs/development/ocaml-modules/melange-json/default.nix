{
  lib,
  buildDunePackage,
  fetchurl,
  melange,
}:

let
  pname = "melange-json";
  version = "2.0.0";
in
buildDunePackage {
  inherit pname version;
  src = fetchurl {
    url = "https://github.com/melange-community/${pname}/releases/download/${version}/${pname}-${version}.tbz";
    hash = "sha256-UEnBaUrDD33j2//BDpoBuDwzArQUeQLZfDG3SC/bKtg=";
  };
  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];
  doCheck = false; # Fails due to missing "melange-jest", which in turn fails in command "npx jest" due to restricted network access
  meta = {
    description = "Compositional JSON encode/decode library and PPX for Melange";
    homepage = "https://github.com/melange-community/${pname}";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.vog ];
  };
}
