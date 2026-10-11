# Sourced by the release build scripts (not run directly).
#
# Loads Sentry settings from the gitignored .sentry.env, then sets
# SENTRY_DEFINES (flutter build flags) and upload_sentry_symbols. The release
# name matches what the app reports, so crashes and symbols line up.

if [ -f .sentry.env ]; then
  set -a
  # shellcheck source=/dev/null
  . ./.sentry.env
  set +a
fi

app_version="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml)"
export SENTRY_RELEASE="cm.scoreboards.app@${app_version}"

SENTRY_DEFINES=()
if [ -n "${SENTRY_DSN:-}" ]; then
  SENTRY_DEFINES=(
    "--dart-define=SENTRY_DSN=${SENTRY_DSN}"
    "--dart-define=SENTRY_RELEASE=${SENTRY_RELEASE}"
  )
else
  echo "warning: SENTRY_DSN not set (see .sentry.env.example); building without crash reporting." >&2
fi

upload_sentry_symbols() {
  if [ -z "${SENTRY_DSN:-}" ]; then
    return
  fi
  local missing=()
  for var in SENTRY_AUTH_TOKEN SENTRY_ORG SENTRY_PROJECT; do
    [ -n "${!var:-}" ] || missing+=("$var")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "warning: ${missing[*]} not set (see .sentry.env.example); debug symbols not uploaded, so crash stack traces won't be readable." >&2
    return
  fi
  dart run sentry_dart_plugin
}
