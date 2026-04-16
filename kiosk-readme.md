# Single HDMI Kiosk Setup

Raspberry Pi 4 running Debian 13 (trixie). Displays one website from a private GitHub repo on a single HDMI output, in full-screen kiosk mode. Single-screen fork of [pi-two-screen-kiosk](https://github.com/HawkinsJM/pi-two-screen-kiosk) to reduce RAM usage.

## Files

| File | Purpose |
|---|---|
| `~/kiosk.conf` | Configure which site shows and its rotation |
| `~/kiosk-start.sh` | X session script — starts openbox, detects monitor, launches browser |
| `~/kiosk-update.sh` | Pull latest from GitHub and restart the kiosk |
| `~/softsystems/` | Cloned repo (static HTML sites) |
| `/etc/systemd/system/kiosk.service` | Systemd service — auto-starts on boot |
| `/etc/nginx/sites-available/softsystems` | Nginx config — serves the repo at localhost |

## Available Sites

| File | Title |
|---|---|
| `8.html` | A Compass of Lunar Trigrams |
| `9.html` | K9-tailed |
| `10.html` | X/十/10: Wheel of Fortune |
| `11.html` | Smoke Signals |
| `12.html` | FLUXIIS |
| `13.html` | Coyote Spotting Simulator |
| `14.html` | Field Sonata |
| `15.html` | Of Mountains and Seas |

## Changing Which Site Is Displayed

Edit `~/kiosk.conf`:

```bash
DISPLAY1_SITE=10.html
DISPLAY1_ROTATE=normal
```

Then restart the kiosk:

```bash
sudo systemctl restart kiosk
```

## Pulling New Content from GitHub

```bash
~/kiosk-update.sh
```

This does a `git pull` on the repo and restarts the kiosk automatically.

## Common Commands

| Task | Command |
|---|---|
| Start kiosk | `sudo systemctl start kiosk` |
| Stop kiosk | `sudo systemctl stop kiosk` |
| Restart kiosk | `sudo systemctl restart kiosk` |
| Check status | `sudo systemctl status kiosk` |
| View live logs | `journalctl -u kiosk -f` |
| Pull from GitHub | `~/kiosk-update.sh` |

## How It Works

1. On boot, systemd starts the `kiosk` service as the `jeff` user.
2. `xinit` launches an X server on VT7 and runs `kiosk-start.sh`.
3. The script disables screen blanking, starts `openbox` (minimal window manager), and runs `xrandr --auto` to enable the HDMI output.
4. It detects the display resolution and launches a single Chromium instance in kiosk mode using the site configured in `kiosk.conf`.
5. Nginx serves `/home/jeff/softsystems` at `http://localhost` so the browser loads via HTTP (avoids browser file:// restrictions).

## GitHub Repo

- **Repo:** `shewolfe/softsystems` (private)
- **Local path:** `/home/jeff/softsystems`
- **Auth:** GitHub CLI (`gh`) authenticated as HawkinsJM
