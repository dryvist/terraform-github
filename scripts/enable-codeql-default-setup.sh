#!/usr/bin/env bash
#
# Idempotently enable free CodeQL default-setup on every public org repo
# with a supported language.
#
# Code scanning default setup is FREE on public repos (no GHAS license
# consumed). Private repos are never targeted — they require GHAS Code
# Security ($30/committer/month, AGENTS.md "Cost policy") which the
# org policy keeps off as an org default. Per-repo opt-in on cost-approved
# private repos can be added later by extending the filter; not in scope
# here.
#
# Workaround for a provider gap: integrations/terraform-provider-github
# does not expose a resource for
# PUT /repos/{owner}/{repo}/code-scanning/default-setup. When upstream
# ships one this script becomes a one-shot import-style helper and the
# .tf takes over; until then, run after every new public repo joins.
#
# Idempotent: already-configured repos no-op; repos with no supported
# language are skipped. Re-running prints "skip" for every repo and
# touches nothing.
#
# Requires: gh (authenticated with admin:org or administration:write on
# the org — the ORG_ADMIN tier per AGENTS.md "Applying"), jq.

set -euo pipefail

OWNER="dryvist"
enabled=0
already_on=0
skipped_no_lang=0
errors=0

# --visibility public is the safety belt: a private repo name can never
# reach the PUT call. Belt-and-suspenders: GHAS isn't enabled at the org
# default level, so even an accidental PUT against a private repo would
# 403 — no charge can land.
while IFS= read -r name; do
  body=$(gh api "repos/$OWNER/$name/code-scanning/default-setup" 2>/dev/null || echo "")
  if [[ -z "$body" ]]; then
    echo "  ERROR  $name (GET failed)"
    errors=$((errors + 1))
    continue
  fi

  state=$(printf %s "$body" | jq -r '.state // ""')
  langs=$(printf %s "$body" | jq -r '.languages // [] | join(",")')

  if [[ "$state" == "configured" ]]; then
    echo "  skip   $name (already on)"
    already_on=$((already_on + 1))
    continue
  fi

  if [[ -z "$langs" ]]; then
    echo "  skip   $name (no supported language)"
    skipped_no_lang=$((skipped_no_lang + 1))
    continue
  fi

  if gh api --method PUT "repos/$OWNER/$name/code-scanning/default-setup" -f state=configured > /dev/null 2>&1; then
    echo "  ON     $name (langs: $langs)"
    enabled=$((enabled + 1))
  else
    echo "  ERROR  $name (PUT failed)"
    errors=$((errors + 1))
  fi
done < <(gh repo list "$OWNER" --no-archived --visibility public --limit 100 --json name --jq '.[].name' | sort)

echo
echo "enabled: $enabled · already-on: $already_on · skipped-no-lang: $skipped_no_lang · errors: $errors"
