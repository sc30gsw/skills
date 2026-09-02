#!/usr/bin/env bash
# check-references.sh <skill-dir> [repo-root]
#
# Extract every checkable reference from a skill's Markdown and
# report whether it resolves. Read-only. Bash 3.2 compatible.
#
# Output (TSV, header line starts with #):
#   location  kind  token  state  note
#     kind   link        relative Markdown link target
#            path        backticked token with a slash or a file extension,
#                        or a path argument in a fenced shell block
#            command     first word of a command in a fenced bash/sh/zsh/fish block
#            identifier  backticked code-like token (has uppercase, digit, _, - or .)
#            skill       slash-command reference such as /triage
#            orphan      file in the skill directory no Markdown in the skill mentions
#     state  resolved      exists / on PATH / found in the repository
#            missing       path or link with a slash that does not exist
#            candidate     bare filename not found, identifier with no match,
#                          slash command with no project skill of that name, or orphan
#            unverifiable  command not on PATH (prerequisite: install it)
#
# A `missing` row is a broken reference unless the skill's own text says it creates
# that path or offers it as an example. This script reports; the maintainer decides.
#
# Paths resolve against the Markdown file's directory, the skill directory, and
# the repository root, in that order. Globs are expanded (in bash 3.2, ** acts as *).
# Tokens containing spaces, placeholders (< > { } $ [ ]), URLs, or shell
# operators are skipped. Identifier lookups grep the repository once per token.

set -eu

usage() { echo "usage: check-references.sh <skill-dir> [repo-root]" >&2; exit 2; }
[ $# -ge 1 ] || usage
case "$1" in -h|--help) usage ;; esac

skill="$1"
[ -d "$skill" ] || { echo "not a directory: $skill" >&2; exit 2; }
skill="$(cd "$skill" && pwd -P)"
root="${2:-}"
if [ -z "$root" ]; then
  root="$(cd "$skill" && git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
fi
root="$(cd "$root" && pwd -P)"

out="$(mktemp)"
trap 'rm -f "$out"' EXIT
tab="$(printf '\t')"

emit() { printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" >> "$out"; }

strip_quotes() { t="$1"; t="${t#\"}"; t="${t%\"}"; t="${t#\'}"; t="${t%\'}"; printf '%s' "$t"; }

# path_exists TOKEN FILEDIR
path_exists() {
  t="$1"; fd="$2"
  case "$t" in
    /*) [ -e "$t" ] && return 0 || return 1 ;;
    "~"*) return 1 ;;
  esac
  for base in "$fd" "$skill" "$root"; do
    [ -e "$base/$t" ] && return 0
    case "$t" in
      *\**|*\?*)
        if ( cd "$base" 2>/dev/null && shopt -s nullglob && set -- $t && [ $# -gt 0 ] ); then return 0; fi ;;
    esac
  done
  return 1
}

# project_skill_exists NAME: is there a project skill directory with this name?
project_skill_exists() {
  for r in .agents/skills .claude/skills .cursor/skills .codex/skills skills; do
    [ -d "$root/$r" ] || continue
    if find -L "$root/$r" -maxdepth 5 -type f -path "*/$1/SKILL.md" -not -path '*/node_modules/*' 2>/dev/null | grep -q .; then
      return 0
    fi
  done
  return 1
}

is_builtin() {
  case "$1" in
    cd|echo|export|set|unset|if|then|else|elif|fi|for|do|done|while|until|case|esac|function|return|exit|source|.|\[|\[\[|test|true|false|shift|read|local|eval|exec|trap|printf|pushd|popd|command|type|wait|kill|alias|declare|typeset|let|break|continue|time|\{|\}|\!|in|select) return 0 ;;
  esac
  return 1
}

is_interpreter() {
  case "$1" in bash|sh|zsh|fish|dash|node|python|python3|perl|ruby|bun|deno|sudo|env|nohup) return 0 ;; esac
  return 1
}

# check_path_token LOCATION TOKEN FILEDIR STRICT(1|0)
check_path_token() {
  if path_exists "$2" "$3"; then
    emit "$1" path "$2" resolved ""
  elif [ "$4" = 1 ]; then
    emit "$1" path "$2" missing "not found from file dir, skill dir, or repo root"
  else
    emit "$1" path "$2" candidate "bare filename not found; may be generic"
  fi
}

# check_command_word LOCATION WORD FILEDIR
check_command_word() {
  w="$(strip_quotes "$2")"
  [ -n "$w" ] || return 0
  is_builtin "$w" && return 0
  case "$w" in
    */*) check_path_token "$1" "$w" "$3" 1; return 0 ;;
  esac
  if command -v "$w" >/dev/null 2>&1; then
    emit "$1" command "$w" resolved ""
  else
    emit "$1" command "$w" unverifiable "command not on PATH (prerequisite: install $w)"
  fi
}

find "$skill" -type f -name '*.md' -not -path '*/node_modules/*' | LC_ALL=C sort | while IFS= read -r f; do
  rel="${f#$skill/}"
  fd="$(dirname "$f")"

  # 1. Relative Markdown links.
  grep -noE '\]\([^)]+\)' "$f" 2>/dev/null | while IFS= read -r m; do
    ln="${m%%:*}"; tgt="${m#*:}"; tgt="${tgt#\](}"; tgt="${tgt%\)}"; tgt="${tgt%% *}"
    case "$tgt" in http://*|https://*|mailto:*|\#*|'') continue ;; esac
    tgt="${tgt%%#*}"; [ -n "$tgt" ] || continue
    if [ -e "$fd/$tgt" ] || [ -e "$root/$tgt" ]; then
      emit "$rel:$ln" link "$tgt" resolved ""
    else
      emit "$rel:$ln" link "$tgt" missing "relative link target not found"
    fi
  done

  # 2. Backticked tokens: paths and identifiers.
  grep -noE '`[^`]+`' "$f" 2>/dev/null | while IFS= read -r m; do
    ln="${m%%:*}"; tok="${m#*:}"; tok="${tok#\`}"; tok="${tok%\`}"
    case "$tok" in
      *' '*|*"$tab"*|http://*|https://*|*'<'*|*'>'*|*'{'*|*'}'*|*'$'*|*'['*|*']'*|*'|'*|*'('*|*')'*|*'='*|*':'*|-*|*'"'*|*"'"*) continue ;;
    esac
    # A single-segment lowercase token like /triage is a slash-command skill reference.
    if printf '%s' "$tok" | grep -qE '^/[a-z0-9][a-z0-9-]*$'; then
      sname="${tok#/}"
      if project_skill_exists "$sname"; then
        emit "$rel:$ln" skill "$tok" resolved ""
      else
        emit "$rel:$ln" skill "$tok" candidate "no project skill named $sname; may be a global or plugin skill"
      fi
      continue
    fi
    hasslash=0; case "$tok" in */*) hasslash=1 ;; esac
    if [ "$hasslash" = 1 ] || printf '%s' "$tok" | grep -qE '\.[A-Za-z0-9]{1,6}$'; then
      check_path_token "$rel:$ln" "$tok" "$fd" "$hasslash"
    elif printf '%s' "$tok" | grep -qE '^[A-Za-z_][A-Za-z0-9_.-]{2,}$' && printf '%s' "$tok" | grep -qE '[A-Z0-9_.-]'; then
      command -v "$tok" >/dev/null 2>&1 && continue
      if grep -rIlF --exclude-dir=.git --exclude-dir=node_modules -- "$tok" "$root" 2>/dev/null | grep -v "^$skill/" | grep -q .; then
        emit "$rel:$ln" identifier "$tok" resolved ""
      else
        emit "$rel:$ln" identifier "$tok" candidate "no match in the repository outside the skill directory"
      fi
    fi
  done

  # 3. Fenced shell blocks: commands and their path arguments.
  awk '
    /^[[:space:]]*```/ {
      if (inblk) { inblk = 0; next }
      lang = $0; sub(/^[[:space:]]*```[[:space:]]*/, "", lang); sub(/[[:space:]].*$/, "", lang)
      if (lang ~ /^(bash|sh|shell|zsh|fish)$/) inblk = 1
      next
    }
    inblk { print NR "\t" $0 }
  ' "$f" | while IFS="$tab" read -r ln line; do
    line="${line#"${line%%[![:space:]]*}"}"
    case "$line" in ''|\#*) continue ;; esac
    line="${line#\$ }"
    printf '%s\n' "$line" | awk '{ n = split($0, a, /\|\||&&|;|\|/); for (i = 1; i <= n; i++) print a[i] }' | while IFS= read -r seg; do
      seg="${seg#"${seg%%[![:space:]]*}"}"
      # Drop leading VAR=value assignments.
      while :; do
        w="${seg%% *}"
        if printf '%s' "$w" | grep -qE '^[A-Za-z_][A-Za-z0-9_]*='; then
          if [ "$w" = "$seg" ]; then seg=""; break; fi
          seg="${seg#* }"
        else
          break
        fi
      done
      [ -n "$seg" ] || continue
      first="${seg%% *}"
      rest="${seg#"$first"}"; rest="${rest# }"
      if is_interpreter "$first"; then
        second="${rest%% *}"; second="$(strip_quotes "$second")"
        case "$second" in -*|'') continue ;; esac
        case "$second" in
          */*|*.sh|*.bash|*.js|*.mjs|*.cjs|*.ts|*.py|*.rb|*.pl) check_path_token "$rel:$ln" "$second" "$fd" 1 ;;
        esac
        continue
      fi
      check_command_word "$rel:$ln" "$first" "$fd"
    done
  done
done

# 4. Orphans: files in the skill directory that no Markdown in the skill mentions.
find "$skill" -type f -not -path '*/node_modules/*' -not -name 'SKILL.md' -not -path "$skill/agents/openai.yaml" | LC_ALL=C sort | while IFS= read -r f; do
  rel="${f#$skill/}"; base="$(basename "$f")"
  if grep -rlF --include='*.md' -- "$rel" "$skill" 2>/dev/null | grep -v "^$f\$" | grep -q . \
     || grep -rlF --include='*.md' -- "$base" "$skill" 2>/dev/null | grep -v "^$f\$" | grep -q .; then
    :
  else
    emit "$rel" orphan "$rel" candidate "not referenced from any Markdown in the skill"
  fi
done

printf '#location\tkind\ttoken\tstate\tnote\n'
LC_ALL=C sort -u "$out"
awk -F'\t' '{ c[$4]++ } END { printf "summary:"; for (k in c) printf " %s=%d", k, c[k]; printf "\n" }' "$out" >&2
