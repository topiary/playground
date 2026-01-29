#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 ]]; then
  GREEN="$(tput setaf 2)"
  ORANGE="$(tput setaf 3)"
  RESET="$(tput sgr0)"
else
  GREEN=""
  ORANGE=""
  RESET=""
fi
readonly ORANGE GREEN RESET

stderr() {
  local colour="$1"
  shift

  printf "%s%s%s\n" "${colour}" "$*" "${RESET}" >&2
}

usage() {
  cat <<-EOF
	usage: $(basename "$0") TOPIARY_REPO

	Build the languages export per the Topiary repository specified by
	TOPIARY_REPO.
	EOF

  exit 1
}

get-language-info() {
  # Read the supported language assets from the Topiary repository and
  # stream out a tab-delimited list of language, query file and example
  # input file
  local repo="$1"
  local language
  local query
  local example

  for query in "${repo}/topiary-queries/queries/"*.scm; do
    language="$(basename --suffix ".scm" "${query}")"

    # ocaml_interface is an annoying special case
    if [[ "${language}" = "ocaml_interface" ]]; then
      language="ocaml-interface"
    fi

    example="$(find "${repo}/topiary-cli/tests/samples/input" -name "${language}.*")"

    printf "%s\t%s\t%s\n" "${language}" "${query}" "${example}"
  done
}

to-js-string() {
  sed '
    # Escape the escape character (must be done first)
    s/\\/\\\\/g;

    # Backticks are delimiters for template literals in JavaScript
    s/`/\\`/g;

    # Escape braced template literals
    s/${/\\${/g
  '
}

export-language() {
  local language="$1"
  local query="$2"
  local example="$3"

  stderr "${ORANGE}" "${language}: Exporting query and example"

  cat <<-TYPESCRIPT
  "${language}": {
    "query": \`$(to-js-string < "${query}")\`,
    "input": \`$(to-js-string < "${example}")\`,
  },
TYPESCRIPT
}

main() {
  local repo="$1"

  {
    # Write output header
    cat <<-TYPESCRIPT
		const languages: {[index: string]: any} = {
		TYPESCRIPT

    # Write export for each language
    get-language-info "${repo}" \
    | while read -r language query example; do
      export-language "${language}" "${query}" "${example}"
    done

    # Write output footer
    cat <<-TYPESCRIPT
		};

		export default languages;
		TYPESCRIPT
  } > languages_export.ts

  stderr "${GREEN}" "Done! All languages have been exported"
}

(( $# != 1 )) && usage
main "$@"
