#!/usr/bin/env bash

set -euo pipefail

export OPAMROOT=$HOME/code/segfault/opam-repo-ci/.opam-revdeps/
export OPAMSWITCH=default

PKG="${1:-}"

if [ -z "${PKG}" ]; then
  echo "Need a pkg name with version!"
  exit 1
fi

function revdeps_opam() {
  REVDEPS=$(opam list -s --color=never --depends-on "$1" --coinstallable-with "$1" --all-versions --depopts;
            opam list -s --color=never --depends-on "$1" --coinstallable-with "$1" --all-versions --recursive;
            opam list -s --color=never --depends-on "$1" --coinstallable-with "$1" --all-versions --with-test --depopts)

  echo "$REVDEPS"|sort|uniq
}

function revdeps_opam_ci_check {
  dune exec -- opam-ci-check list "$1" | sort | uniq
}

function compare_revdeps {
  local pkg="$1"
  output_file="$1"

  if [ -f "exp/${output_file}.opam" ]; then
    echo "Using cached opam revdeps for $1"
  else
    echo "Getting revdeps for $1 using opam list... (this may take a while)"
    revdeps_opam "$pkg" > "exp/${output_file}.opam"
  fi

  if [ -f "exp/${output_file}.check" ]; then
    echo "Using cached opam-ci-check revdeps for $1"
  else
    echo "Getting revdeps for $1 using opam-ci-check..."
    revdeps_opam_ci_check "$pkg" > "exp/${output_file}.check"
  fi

  diff "exp/${output_file}.opam" "exp/${output_file}.check" || true
}

mkdir -p exp/
compare_revdeps "$PKG"
