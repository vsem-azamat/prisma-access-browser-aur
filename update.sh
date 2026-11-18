#!/usr/bin/env bash
# Bump PKGBUILD to the newest stable build in Palo Alto's official apt repository.
# The checksum is taken from the repository index, not computed from a download.
# Prints "updated=<version>" when PKGBUILD changed, "current=<version>" otherwise.
set -euo pipefail

readonly INDEX_URL="https://updates.talon-sec.com/linux/prisma-access-browser/deb/dists/stable/main/binary-amd64/Packages"
readonly DEB_PACKAGE="prisma-access-browser-stable"

cd "$(dirname "$0")"

index=$(curl -fsSL --retry 3 "$INDEX_URL")

# One "version sha256" line per build of the stable package.
builds=$(awk -v pkg="$DEB_PACKAGE" '
	/^Package: / { in_pkg = ($2 == pkg); ver = ""; sha = "" }
	in_pkg && /^Version: / { ver = $2 }
	in_pkg && /^SHA256: / { sha = $2 }
	/^$/ { if (in_pkg && ver != "" && sha != "") print ver, sha; in_pkg = 0 }
	END { if (in_pkg && ver != "" && sha != "") print ver, sha }
' <<<"$index")

latest=$(sort -V -k1,1 <<<"$builds" | tail -n1)
[[ -n "$latest" ]] || { echo "no $DEB_PACKAGE builds found in $INDEX_URL" >&2; exit 1; }

read -r deb_version sha256 <<<"$latest"
upstream_ver=${deb_version%-*} # 157.19.6.79-1 -> 157.19.6.79
[[ "$upstream_ver" =~ ^[0-9]+(\.[0-9]+)+$ ]] || { echo "unexpected version: $deb_version" >&2; exit 1; }
[[ "$sha256" =~ ^[0-9a-f]{64}$ ]] || { echo "unexpected sha256: $sha256" >&2; exit 1; }

current_ver=$(sed -n 's/^pkgver=//p' PKGBUILD)
if [[ "$(printf '%s\n%s\n' "$current_ver" "$upstream_ver" | sort -V | tail -n1)" == "$current_ver" ]]; then
	echo "current=$current_ver"
	exit 0
fi

sed -i \
	-e "s/^pkgver=.*/pkgver=$upstream_ver/" \
	-e "s/^pkgrel=.*/pkgrel=1/" \
	-e "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('$sha256')/" \
	PKGBUILD
makepkg --printsrcinfo >.SRCINFO

echo "updated=$upstream_ver"
