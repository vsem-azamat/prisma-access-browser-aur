# prisma-access-browser-aur

Arch Linux packaging for [Prisma Access Browser](https://docs.paloaltonetworks.com/prisma-access-browser),
published in the AUR as [`prisma-access-browser-bin`](https://aur.archlinux.org/packages/prisma-access-browser-bin).

Palo Alto Networks ships the browser for Linux only as `.deb` and `.rpm` packages. This package takes the
official stable `.deb`, unpacks it into `/opt/paloaltonetworks/pab`, installs the icons and drops the Debian
cron job, which does nothing on Arch.

The browser itself is proprietary. This repository contains only the build recipe: `makepkg` downloads the
binary from Palo Alto's own server (`updates.talon-sec.com`) and checks it against the SHA256 published in
their repository index. Nothing from Palo Alto is redistributed here. Using the browser requires an
organisation with a Prisma Browser license.

## Install

```sh
yay -S prisma-access-browser-bin
```

Or build from this repository:

```sh
git clone https://github.com/vsem-azamat/prisma-access-browser-aur
cd prisma-access-browser-aur
makepkg -si
```

The browser does not update itself on Linux; new versions arrive through package updates.

## Differences from the official .deb

The `.deb` runs a post-install script that this package does not run as is. What it does and how it is
handled here:

| `.deb` post-install step | This package |
|---|---|
| Adds a daily cron job and an apt repository for updates | Dropped; pacman handles updates |
| Installs and **starts** `pab-protection.service`, an eBPF service that blocks `ptrace` on the browser's processes | Ships the same unit as `/usr/lib/systemd/system/pab-protection.service`, **disabled** |
| Edits the GRUB command line to enable BPF LSM | Not done; the bootloader is left alone |
| Sets up Device Trust key management when `/etc/default/prisma-access-browser` contains `install_device_trust_key_management_command=true` | Same, from the pacman install script |
| Loads an AppArmor profile on Ubuntu | Not done |

### Protection service

If your organisation enforces browser process protection, the browser refuses to start until the service
runs. To enable it:

1. Make sure BPF LSM is active: `bpf` must appear in `/sys/kernel/security/lsm`. Stock Arch kernels enable it;
   otherwise add `bpf` to the `lsm=` kernel parameter.
2. Install `python-bcc` and the headers for your kernel (`linux-headers`, `linux-lts-headers`, ...).
3. `sudo systemctl enable --now pab-protection.service`

`journalctl -u pab-protection.service` should show `BPF LSM detected: LSM hooks attached automatically`.

## Automatic updates

Palo Alto publishes a new stable build about once a week. A daily GitHub Actions job:

1. runs `update.sh`, which reads the official apt index and takes the newest stable version and its SHA256;
2. builds the package in an `archlinux` container and runs `namcap`;
3. commits the bump here and, when the `AUR_SSH_KEY` secret is set, pushes `PKGBUILD` and `.SRCINFO` to the AUR.

Run the check by hand with `./update.sh`. It prints `updated=<version>` when it changed `PKGBUILD`, or
`current=<version>` when the package is already up to date.

## License

The packaging files are released under [0BSD](LICENSE). Prisma Access Browser is proprietary software of
Palo Alto Networks and is covered by their terms.
