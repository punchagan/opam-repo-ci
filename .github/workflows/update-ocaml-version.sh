#!/bin/bash
# This script updates the ocaml-version constraint in all .opam files in the
# current directory to the latest version available in the opam repository.

set -e

fetch_latest_ocaml_version() {
  latest_version=$(curl -s https://api.github.com/repos/ocaml/opam-repository/contents/packages/ocaml-version | \
    jq -r '.[].name' | \
    grep -E '^ocaml-version\.[0-9]+\.[0-9]+(\.[0-9]+)?$' | \
    sed 's/ocaml-version\.//' | \
    sort -V | \
    tail -n 1)

  echo "$latest_version"
}

update_opam_files() {
  local latest_version=$1

  echo "Updating .opam files with the latest OCaml version: $latest_version"

  for opam_file in *.opam; do
    if grep -q "ocaml-version" "$opam_file"; then
      echo "Updating $opam_file..."
      sed -i "s/\"ocaml-version\" {>= .*}/\"ocaml-version\" {>= \"$latest_version\"}/" "$opam_file"
    else
      echo "No ocaml-version constraint found in $opam_file. Skipping."
    fi
  done
}

latest_version=$(fetch_latest_ocaml_version)
update_opam_files "$latest_version"
