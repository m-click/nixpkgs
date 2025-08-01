{
  config,
  lib,
  fetchFromGitHub,
  erlang,
  makeWrapper,
  coreutils,
  bash,
  buildRebar3,
  buildHex,
}:

{
  baseName ? "lfe",
  version,
  maximumOTPVersion,
  sha256 ? "",
  hash ? "",
  rev ? version,
  src ? fetchFromGitHub {
    inherit hash rev sha256;
    owner = "lfe";
    repo = "lfe";
  },
  patches ? [ ],
}:

let
  inherit (lib)
    assertMsg
    makeBinPath
    optionalString
    getVersion
    versionAtLeast
    versionOlder
    versions
    ;

  mainVersion = versions.major (getVersion erlang);

  maxAssert = versionAtLeast maximumOTPVersion mainVersion;

  proper = buildHex {
    name = "proper";
    version = "1.4.0";

    sha256 = "sha256-GChYQhhb0z772pfRNKXLWgiEOE2zYRn+4OPPpIhWjLs=";
  };

in
if !config.allowAliases && !maxAssert then
  # Don't throw without aliases to not break CI.
  null
else
  assert assertMsg maxAssert ''
    LFE ${version} is supported on OTP <=${maximumOTPVersion}, not ${mainVersion}.
  '';
  buildRebar3 {
    name = baseName;

    inherit src version;

    nativeBuildInputs = [
      makeWrapper
      erlang
    ];
    beamDeps = [ proper ];
    patches = [
      ./fix-rebar-config.patch
      ./dedup-ebins.patch
    ] ++ patches;
    doCheck = true;
    checkTarget = "travis";

    makeFlags = [
      "-e"
      "MANDB=''"
      "PREFIX=$$out"
    ];

    # These installPhase tricks are based on Elixir's Makefile.
    # TODO: Make, upload, and apply a patch.
    installPhase = optionalString (versionOlder version "1.3") ''
      local libdir=$out/lib/lfe
      local ebindir=$libdir/ebin
      local bindir=$libdir/bin

      rm -Rf $ebindir
      install -m755 -d $ebindir
      install -m644 _build/default/lib/lfe/ebin/* $ebindir

      install -m755 -d $bindir

      for bin in bin/lfe{,c,doc,script}; do install -m755 $bin $bindir; done

      install -m755 -d $out/bin
      for file in $bindir/*; do ln -sf $file $out/bin/; done
    '';

    # Thanks again, Elixir.
    postFixup = ''
      # LFE binaries are shell scripts which run erl and lfe.
      # Add some stuff to PATH so the scripts can run without problems.
      for f in $out/bin/*; do
        wrapProgram $f \
          --prefix PATH ":" "${
            makeBinPath [
              erlang
              coreutils
              bash
            ]
          }:$out/bin"
        substituteInPlace $f --replace "/usr/bin/env" "${coreutils}/bin/env"
      done
    '';

    meta = with lib; {
      description = "Best of Erlang and of Lisp; at the same time!";
      longDescription = ''
        LFE, Lisp Flavoured Erlang, is a lisp syntax front-end to the Erlang
        compiler. Code produced with it is compatible with "normal" Erlang
        code. An LFE evaluator and shell is also included.
      '';

      homepage = "https://lfe.io";
      downloadPage = "https://github.com/rvirding/lfe/releases";

      license = licenses.asl20;
      teams = [ teams.beam ];
      platforms = platforms.unix;
    };
  }
