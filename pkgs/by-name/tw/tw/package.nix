{
  fetchFromGitHub,
  lib,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "tw";
  version = "0.0.0+git20260623.594d35d-1";

  src = fetchFromGitHub {
    owner = "samoht";
    repo = "tw";
    rev = "594d35df46ec2afcfe97632923331badf2940b93";
    hash = "sha256-vCRq0FCBIxc/AQg+R2Hig7nqwJGxgy2jedLbAsKaIoA=";
  };

  propagatedBuildInputs = [ ocamlPackages.cascade ];
  buildInputs = [
    ocamlPackages.cmdliner
    ocamlPackages.fmt
  ];

  # Disabling tests because there check for byte-for-byte identical
  # output with tailwindcss, so they are tied to a specific
  # tailwindcss version, and would prevent independent upgrades of tw
  # and tailwindcss.
  doCheck = false;

  minimalOCamlVersion = "5.2";
  duneVersion = "3";

  meta = {
    description = "Type-safe Tailwind CSS v4 in OCaml";
    homepage = "https://github.com/samoht/tw";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vog ];
  };
})
