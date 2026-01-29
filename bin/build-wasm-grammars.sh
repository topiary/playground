#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 ]]; then
  BLUE="$(tput setaf 4)"
  GREEN="$(tput setaf 2)"
  ORANGE="$(tput setaf 3)"
  RESET="$(tput sgr0)"
else
  BLUE=""
  GREEN=""
  ORANGE=""
  RESET=""
fi
readonly BLUE ORANGE GREEN RESET

stderr() {
  local colour="$1"
  shift

  printf "%s%s%s\n" "${colour}" "$*" "${RESET}" >&2
}

# We need to create a temporary working directory on the local
# filesystem because Tree-sitter doesn't work across devices
WORKDIR="$(realpath "$(mktemp --directory --tmpdir=.)")"
readonly WORKDIR
trap 'stderr "${BLUE}" "Cleaning up"; rm -rf "${WORKDIR}"' EXIT

usage() {
  cat <<-EOF
	usage: $(basename "$0") TOPIARY_CONFIG

	Build the grammar WASM binaries for the languages specified in the
	TOPIARY_CONFIG TOML file.
	EOF

  exit 1
}

get-language-info() {
  # Read the Topiary TOML configuration and stream out a tab-delimited
  # list of language, Git repository and revision
  local config="$1"

  nickel export --format json "${config}" \
  | jq -r '
    .languages
    | to_entries[]
    | [.key, .value.grammar.git, .value.grammar.rev]
    | join("\t")
  '
}

build-grammar() {
  local language="$1"
  local repo="$2"
  local rev="$3"

  local checkout="${WORKDIR}/${language}"

  # Optionally allow alternative grammar location within the repo
  local grammar="${checkout}"
  [[ "${4:-}" ]] && grammar+="/$4"

  stderr "${BLUE}" "${language}: Fetching"
  {
    git clone "${repo}" "${checkout}"
    pushd "${checkout}"
    git checkout "${rev}"
    popd
  } >/dev/null 2>&1

  stderr "${ORANGE}" "${language}: Building"
  tree-sitter build --wasm "${grammar}" >/dev/null 2>&1

  stderr "${GREEN}" "${language}: Done"
}

main() {
  local config="$1"

  (
    trap 'kill 0' SIGINT

    while read -r language repo rev; do
      case "${language}" in
        ocaml)
          build-grammar "${language}" "${repo}" "${rev}" "ocaml"
          ;;

        ocaml_interface)
          build-grammar "${language}" "${repo}" "${rev}" "interface"
          ;;

        *)
          build-grammar "${language}" "${repo}" "${rev}"
          ;;
      esac &
    done < <(get-language-info "${config}")

    wait
    stderr "${GREEN}" "Done! All grammars have been built"
  )
}

(( $# != 1 )) && usage
main "$@"
