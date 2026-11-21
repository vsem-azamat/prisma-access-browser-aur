# Maintainer: mnabila <nblid48 at gmail com>

# Version bumps are automated: https://github.com/vsem-azamat/prisma-access-browser-aur

pkgname=prisma-access-browser-bin
_pkgname=prisma-access-browser
pkgver=158.19.3.37
pkgrel=1
pkgdesc="Prisma Access Browser - the secure enterprise browser by Palo Alto Networks"
arch=('x86_64')
url="https://docs.paloaltonetworks.com/prisma-access-browser"
license=('custom')
depends=(
	'alsa-lib'
	'gtk3'
	'libcups'
	'libxss'
	'libxtst'
	'nss'
	'ttf-liberation'
	'xdg-utils'
)
optdepends=(
	'pipewire: WebRTC desktop sharing under Wayland'
	'kdialog: for file dialogs in KDE'
	'gnome-keyring: for storing passwords in GNOME keyring'
	'kwallet: for storing passwords in KWallet'
	'python-bcc: process protection service (pab-protection.service)'
	'linux-headers: kernel headers for the protection service (match your kernel)'
)
provides=("$_pkgname")
conflicts=("$_pkgname")
options=('!emptydirs' '!strip')
install=$pkgname.install
_channel=stable
source=('pab-protection.service')
source_x86_64=("https://updates.talon-sec.com/linux/${_pkgname}/deb/pool/stable/main/${_pkgname}-${_channel}_${pkgver}-1_amd64.deb")
sha256sums=('21c63288fcdda7699663e47b8ddd323f366c9c1bd736656f33f0fcff0a60f9d8')
sha256sums_x86_64=('27618b56f4123e54677589ed2fff071b464717857ac1697f2fe226abf001fff0')

package() {
	bsdtar -xf data.tar.xz -C "$pkgdir/"

	# Icons
	for i in 16 24 32 48 64 128 256; do
		install -Dm644 "$pkgdir/opt/paloaltonetworks/pab/product_logo_${i}.png" \
			"$pkgdir/usr/share/icons/hicolor/${i}x${i}/apps/${_pkgname}.png"
	done

	# Remove the Debian cron job and duplicate product logos
	rm -r \
		"$pkgdir/etc/cron.daily/" \
		"$pkgdir/opt/paloaltonetworks/pab/cron/" \
		"$pkgdir/opt/paloaltonetworks/pab/product_logo_"*.png

	# Protection service, disabled by default. The official postinst restricts its files to root.
	install -Dm644 "$srcdir/pab-protection.service" "$pkgdir/usr/lib/systemd/system/pab-protection.service"
	chmod 500 \
		"$pkgdir/opt/paloaltonetworks/pab/linux_protector"*.py \
		"$pkgdir/opt/paloaltonetworks/pab/protector_filter"*.c
}
