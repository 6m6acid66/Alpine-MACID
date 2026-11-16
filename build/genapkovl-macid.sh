#!/bin/sh -e
# Generate the MACID identity overlay included in the live ISO.
HOSTNAME="${1:-macid}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

makefile() {
  owner="$1"
  perms="$2"
  file="$3"
  mkdir -p "$(dirname "$file")"
  cat > "$file"
  chown "$owner" "$file"
  chmod "$perms" "$file"
}

mkdir -p "$tmp/etc/profile.d" "$tmp/usr/local/bin"

makefile root:root 0644 "$tmp/etc/hostname" <<EOF
$HOSTNAME
EOF

makefile root:root 0644 "$tmp/etc/motd" <<'EOF'
  __  __    _    ____ ___ ____
 |  \/  |  / \  / ___|_ _|  _ \
 | |\/| | / _ \| |    | || | | |
 | |  | |/ ___ \ |___ | || |_| |
 |_|  |_/_/   \_\____|___|____/

MACID OS | Alpine-based x86_64 live system
Type 'macid help' to inspect the system.
EOF

makefile root:root 0644 "$tmp/etc/issue" <<'EOF'
MACID OS | Alpine Linux | x86_64
EOF

makefile root:root 0644 "$tmp/etc/profile.d/macid.sh" <<'EOF'
# MACID shell identity. Compatible with BusyBox ash.
export MACID_OS=1
export PS1='MACID \u@\h:\w# '
alias ll='ls -alF'
alias la='ls -A'
EOF

makefile root:root 0755 "$tmp/usr/local/bin/macid" <<'EOF'
#!/bin/sh
set -eu
VERSION="0.1.0-foundation"
case "${1:-help}" in
  help|-h|--help)
    printf '%s\n' 'MACID OS command center' '' \
      'Usage: macid <command>' '' \
      '  help       Show this help' \
      '  version    Show MACID and Alpine versions' \
      '  status     Show kernel, architecture, and hostname' \
      '  identity   Show the MACID system identity'
    ;;
  version)
    printf 'MACID OS %s\n' "$VERSION"
    if [ -r /etc/alpine-release ]; then
      printf 'Alpine %s\n' "$(cat /etc/alpine-release)"
    fi
    ;;
  status)
    printf 'System: '; uname -srm
    printf 'Hostname: '; hostname
    printf 'Alpine: '; cat /etc/alpine-release 2>/dev/null || echo unknown
    printf 'MACID: %s\n' "$VERSION"
    ;;
  identity)
    printf '%s\n' 'MACID OS' 'Base: Alpine Linux' 'Architecture: x86_64' 'Init: OpenRC'
    ;;
  *)
    printf 'Unknown MACID command: %s\n' "$1" >&2
    printf '%s\n' "Run 'macid help' for commands." >&2
    exit 2
    ;;
esac
EOF

tar -czf "$HOSTNAME.apkovl.tar.gz" -C "$tmp" etc usr
