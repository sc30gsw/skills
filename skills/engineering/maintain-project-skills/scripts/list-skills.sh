#!/usr/bin/env bash
# list-skills.sh [repo-root]
#
# Enumerate every skill installed in a project, mark each as owned or vendored,
# and for vendored skills check whether the directory still matches the hash
# recorded in skills-lock.json. Read-only. Bash 3.2 compatible.
#
# Output (TSV, header line starts with #):
#   path  dir_name  frontmatter_name  kind  status
#     kind    owned | vendored
#     status  owned                       (owned skills)
#             match | modified | unknown  (vendored skills)
#
# Vendored means the directory name appears under "skills" in the project's
# root skills-lock.json, the lock written by `npx skills add`. No lock file
# means every skill is owned.
#
# Hash reproduction needs `node`: the CLI sorts relative paths with
# String.prototype.localeCompare (ICU collation) before hashing, which plain
# `sort` cannot reproduce. Without node, or when the lock has no hash for the
# entry, status is `unknown`.

set -eu

case "${1:-}" in
  -h|--help) echo "usage: list-skills.sh [repo-root]" >&2; exit 2 ;;
esac

root="${1:-}"
if [ -z "$root" ]; then
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
fi
cd "$root" || exit 2
root="$(pwd -P)"

dirs="$(mktemp)"
lock_tsv="$(mktemp)"
trap 'rm -f "$dirs" "$lock_tsv"' EXIT

# 1. Enumerate SKILL.md under the roots agents read, follow symlinks, dedupe by real path.
for r in .agents/skills .claude/skills .cursor/skills .codex/skills skills; do
  [ -d "$r" ] || continue
  find -L "$r" -maxdepth 5 -type f -name SKILL.md -not -path '*/node_modules/*' 2>/dev/null || true
done | while IFS= read -r f; do
  d="$(cd "$(dirname "$f")" 2>/dev/null && pwd -P)" || continue
  printf '%s\n' "$d"
done | LC_ALL=C sort -u > "$dirs"

# 2. Parse the lock: one line per entry, "name<TAB>computedHash-or-dash".
#    The lock is machine-written JSON (JSON.stringify with two-space indent); this
#    brace-depth walk is enough for that shape and degrades to "no entries" otherwise.
if [ -f skills-lock.json ]; then
  awk '
    BEGIN { inskills = 0; depth = 0; key = ""; hash = "-" }
    !inskills && /"skills"[[:space:]]*:[[:space:]]*\{/ { inskills = 1; next }
    inskills {
      if (depth == 0) {
        if ($0 ~ /^[[:space:]]*\}/) { inskills = 0; next }
        if ($0 ~ /^[[:space:]]*"[^"]+"[[:space:]]*:[[:space:]]*\{/) {
          key = $0; sub(/^[[:space:]]*"/, "", key); sub(/".*$/, "", key); hash = "-"
          depth = gsub(/\{/, "{") - gsub(/\}/, "}")
          if (depth <= 0) { print key "\t" hash; depth = 0 }
        }
        next
      }
      if (match($0, /"computedHash"[[:space:]]*:[[:space:]]*"[0-9a-fA-F]+"/)) {
        s = substr($0, RSTART, RLENGTH); sub(/^.*:[[:space:]]*"/, "", s); sub(/"$/, "", s); hash = s
      }
      depth += gsub(/\{/, "{") - gsub(/\}/, "}")
      if (depth <= 0) { print key "\t" hash; depth = 0; key = "" }
    }
  ' skills-lock.json > "$lock_tsv" || true
fi

have_node=0
command -v node >/dev/null 2>&1 && have_node=1

# Reproduce the CLI's computeSkillFolderHash: walk files (skip .git and
# node_modules, skip symlinks), sort by localeCompare, hash path then content.
hash_dir() {
  node -e '
    const fs = require("fs"), path = require("path"), crypto = require("crypto");
    const base = process.argv[1];
    const files = [];
    (function walk(d) {
      for (const e of fs.readdirSync(d, { withFileTypes: true })) {
        const p = path.join(d, e.name);
        if (e.isDirectory()) { if (e.name === ".git" || e.name === "node_modules") continue; walk(p); }
        else if (e.isFile()) files.push({ rel: path.relative(base, p).split("\\").join("/"), content: fs.readFileSync(p) });
      }
    })(base);
    files.sort((a, b) => a.rel.localeCompare(b.rel));
    const h = crypto.createHash("sha256");
    for (const f of files) { h.update(f.rel); h.update(f.content); }
    process.stdout.write(h.digest("hex"));
  ' "$1"
}

frontmatter_name() {
  awk '
    NR == 1 && $0 !~ /^---[[:space:]]*$/ { exit }
    NR > 1 && $0 ~ /^---[[:space:]]*$/ { exit }
    /^name:[[:space:]]*/ { s = $0; sub(/^name:[[:space:]]*/, "", s); sub(/[[:space:]]+$/, "", s)
                            gsub(/^["'\''"]|["'\''"]$/, "", s); print s; exit }
  ' "$1/SKILL.md" 2>/dev/null
}

printf '#path\tdir_name\tfrontmatter_name\tkind\tstatus\n'
n_owned=0; n_vendored=0; n_modified=0
while IFS= read -r d; do
  [ -n "$d" ] || continue
  name="$(basename "$d")"
  fm="$(frontmatter_name "$d")"; [ -n "$fm" ] || fm="-"
  lockhash="$(awk -F'\t' -v k="$name" '$1 == k { print $2; exit }' "$lock_tsv")"
  if [ -n "$lockhash" ]; then
    kind=vendored; n_vendored=$((n_vendored + 1))
    if [ "$lockhash" = "-" ] || [ "$have_node" -eq 0 ]; then
      status=unknown
    else
      cur="$(hash_dir "$d" 2>/dev/null || true)"
      if [ "$cur" = "$lockhash" ]; then status=match; else status=modified; n_modified=$((n_modified + 1)); fi
    fi
  else
    kind=owned; status=owned; n_owned=$((n_owned + 1))
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$d" "$name" "$fm" "$kind" "$status"
done < "$dirs"

if [ -f skills-lock.json ]; then lockmsg="skills-lock.json"; else lockmsg="no lock file (all skills owned)"; fi
if [ "$have_node" -eq 1 ]; then nodemsg="node present"; else nodemsg="node absent (vendored status unknown)"; fi
printf 'summary: owned=%d vendored=%d modified=%d; %s; %s\n' "$n_owned" "$n_vendored" "$n_modified" "$lockmsg" "$nodemsg" >&2
