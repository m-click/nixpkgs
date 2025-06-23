{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook_xsl,
  libxslt,
  meson,
  ninja,
  pkg-config,
  bash-completion,
  libcap,
  libselinux,
}:

stdenv.mkDerivation rec {
  pname = "bubblewrap";
  version = "0.11.0";

  src = fetchFromGitHub {
    # See https://github.com/containers/bubblewrap/pull/586
    owner = "aaruni96";
    repo = "bubblewrap";
    rev = "e33e82fc556073332c93c9136c3159c708a158ed";
    hash = "sha256-Tz0qnTWwD4DD0XkXBWEvZPAu4bWRqbjfNsDSPNkUeLA=";
  };

  postPatch = ''
    substituteInPlace tests/libtest.sh \
      --replace "/var/tmp" "$TMPDIR"
  '';

  nativeBuildInputs = [
    docbook_xsl
    libxslt
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bash-completion
    libcap
    libselinux
  ];

  # incompatible with Nix sandbox
  doCheck = false;

  meta = with lib; {
    changelog = "https://github.com/containers/bubblewrap/releases/tag/${src.rev}";
    description = "Unprivileged sandboxing tool";
    homepage = "https://github.com/containers/bubblewrap";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ dotlambda ];
    platforms = platforms.linux;
    mainProgram = "bwrap";
  };
}
