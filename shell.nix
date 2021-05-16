{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs {};

  localPath = ./. + "/local.nix";
  local = import localPath { pkgs = pkgs; };

  defaultPythonPackages = with pkgs.python37Packages; [
    # other python packages you want
    pip
    setuptools
  ];

  finalPythonPackages = if builtins.pathExists localPath then
    defaultPythonPackages ++ local.customPythonPackages
  else
    defaultPythonPackages;

  my-python-packages = python-packages: finalPythonPackages;

  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

  # define packagesto install with special handling for OSX
  basePackages = with pkgs; [
    gnumake
    gcc
    readline
    openssl
    zlib
    libxml2
    curl
    libiconv
    elixir_1_9
    glibcLocales
    nodejs-12_x
    yarn
    postgresql
    inotify-tools
    python-with-my-packages
    selenium-server-standalone
    geckodriver
    nginx
  ];

  inputs = basePackages
    ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.inotify-tools
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
        CoreFoundation
        CoreServices
      ]);

  final = if builtins.pathExists localPath then
    inputs ++ local.customPackages
  else
    inputs;

  # define shell startup command with special handling for OSX
  baseHooks = ''
    export PS1='\n\[\033[1;32m\][nix-shell:\w]($(git rev-parse --abbrev-ref HEAD))\$\[\033[0m\] '

    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.7/site-packages:$PYTHONPATH"
    unset SOURCE_DATE_EPOCH

    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LANG=en_US.UTF-8
    export PATH=$PATH:$(pwd)/_build/pip_packages/bin
    export ERL_AFLAGS="-kernel shell_history enabled"
  '';

  hooks = if builtins.pathExists localPath then
    baseHooks + local.customHooks
  else
    baseHooks;

in pkgs.mkShell {
  buildInputs = final;
  shellHook = hooks;
}
