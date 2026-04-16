# New Pi Setup

Steps to set up a new Raspberry Pi kiosk from scratch.

## Requirements
- Raspberry Pi 4
- Micro-HDMI cable and monitor
- SD card (32GB+)

## Steps

1. Flash **Raspberry Pi OS Lite (64-bit)** — Trixie (Debian 13) or Bookworm (Debian 12) — to the SD card using Raspberry Pi Imager.
   Use **Lite**, not Desktop: the desktop environment wastes ~200–300MB RAM since the kiosk replaces it with xinit + openbox anyway.
   Trixie is the current default in Raspberry Pi Imager and works correctly with this setup.

   In the Imager advanced settings, configure:
   - **SSH**: enable
   - **Username**: `jeff`
   - **Hostname**: e.g. `helen2`
   - **WiFi**: SSID and password for the deployment network

2. Insert the card, plug in monitors, and boot.

3. SSH in:
   ```bash
   ssh jeff@<ip-address>
   ```

4. Allow passwordless sudo (required for scripted installs):
   ```bash
   echo "jeff ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd-jeff
   ```

5. Install the GitHub CLI and authenticate (required to clone private repos):
   ```bash
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
   sudo apt update && sudo apt install gh -y
   gh auth login
   ```
   > Use a **classic** Personal Access Token (not fine-grained) with `repo` scope.
   > Fine-grained tokens cannot access private repos owned by other accounts (e.g. softsystems).

6. Clone the kiosk config repo:
   ```bash
   gh repo clone HawkinsJM/pi-one-screen-kiosk
   ```

7. Run the setup script (installs all packages, fonts, services, and clones softsystems):
   ```bash
   cd pi-one-screen-kiosk && bash setup.sh
   ```
   > The script regenerates SSH host keys — this is only needed when duplicating an SD card image.
   > For a fresh flash it's harmless but will cause a host key warning on your next SSH connection.
   > Skip it if you prefer by pressing Ctrl+C when prompted, then re-running from the next step.

8. Edit the kiosk config to set which sites show on each screen:
   ```bash
   nano ~/kiosk.conf
   ```

9. Reboot:
    ```bash
    sudo reboot
    ```

The kiosk service will start automatically on reboot.

## Display Assignment

| Pi | Hostname | Screen 1 | Screen 2 |
|----|----------|----------|----------|
| j4r | helen1 | 8.html | 9.html |
| — | helen2 | 10.html | 11.html |
| — | helen3 | 12.html | 13.html |
| — | helen4 | 14.html | 15.html |
| — | helen5 | 15.html | — |
