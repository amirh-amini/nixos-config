{
  lib,
  python3Packages,
  fetchFromGitHub,
  cacert,
}:
let
  # tarsafe is not in nixpkgs; it's a tiny pure-Python wrapper around tarfile
  # that guarddog depends on. Its sdist declares the legacy poetry.masonry.api
  # build backend (unavailable in nixpkgs), so we install the prebuilt
  # pure-Python wheel instead — no build step, still hash-pinned/reproducible.
  tarsafe = python3Packages.buildPythonPackage rec {
    pname = "tarsafe";
    version = "0.0.5";
    format = "wheel";

    src = python3Packages.fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-GmqoJVwYHWBw2zsIP22WlgLGMGuj3HyDaiiMwmpcW/8=";
    };

    doCheck = false;
    pythonImportsCheck = [ "tarsafe" ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "guarddog";
  version = "2.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DataDog";
    repo = "guarddog";
    rev = "v${version}";
    hash = "sha256-ayHOGyFlFcY3sxFJCidOX6PaTEyXvEjimizv+uHEgDI=";
  };

  build-system = [ python3Packages.poetry-core ];

  # nixpkgs ships a few of these newer than guarddog's upper bounds
  # (disposable-email-domains, pygit2); they are API-compatible, so relax pins.
  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    click
    configparser
    disposable-email-domains
    prettytable
    python-dateutil
    python-whois
    pygit2
    pyyaml
    requests
    semantic-version
    semgrep # the Semgrep Python module from nixpkgs — NOT pulled from PyPI
    termcolor
    urllib3
    yara-python
    tarsafe
  ];

  # No pythonImportsCheck: importing guarddog pulls in pygit2, which loads
  # system SSL certs at import time — absent in the hermetic build sandbox.
  # We give it a CA bundle and smoke-test the CLI instead.
  doCheck = false; # test suite reaches the network / needs fixtures

  installCheckPhase = ''
    runHook preInstallCheck
    SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt \
      $out/bin/guarddog --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "CLI to identify malicious PyPI and npm packages (Semgrep-based)";
    homepage = "https://github.com/DataDog/guarddog";
    license = lib.licenses.asl20;
    mainProgram = "guarddog";
  };
}