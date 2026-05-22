# VelosterPlay

A DIY wireless CarPlay bridge for a 2020 Hyundai Veloster R-Spec, built on a Raspberry Pi Zero 2 W.

**Status:** Phase 1 — initial setup.

## What this is

The 2020 Veloster ships with wired CarPlay only. Off-the-shelf dongles (Carlinkit, etc.) add wireless support for ~$60 and work fine. This project does the same thing from scratch, on a Pi, with full source access and no closed-source dongle in the loop.

It's a learning project. The end goal is to understand every layer of the CarPlay protocol and the head unit's behavior well enough to build a foundation for deeper modifications down the road.

## How it works (target architecture)

The Pi sits between the iPhone and the head unit:

1. **Pi ↔ head unit (USB):** Pi presents itself as a wired Apple CarPlay device using Linux USB gadget mode. Head unit can't tell the difference.
2. **Pi ↔ iPhone (BLE + Wi-Fi):** Pi advertises wireless CarPlay availability over BLE. iPhone initiates handover. Pi and iPhone establish a Wi-Fi link for A/V transport.
3. **Bridging:** Pi relays H.264 video and audio from iPhone-over-Wi-Fi to head unit-over-USB, and touch/control events the other direction.
4. **MFi auth:** unchanged — the head unit's existing MFi authentication coprocessor still validates with the iPhone, transparently proxied through the Pi.

Built on top of [node-CarPlay](https://github.com/rhysmorgan134/node-CarPlay).

## Hardware

- Raspberry Pi Zero 2 W
- 32GB A2 microSD
- USB OTG cable (micro-USB male ↔ USB-A male, data-capable)

## Roadmap

- **Phase 1:** Wireless CarPlay via Pi bridge. Hidden install in the Veloster.
- **Phase 2:** Dump and reverse engineer the Hyundai head unit firmware.
- **Phase 3:** Custom modifications to the head unit software for navigation and UI improvements.
- **Phase 4:** CarPlay Ultra reverse engineering and integration when the protocol becomes more observable.

## Current status

- USB gadget mode working: Pi presents as USB Ethernet device (ECM)
- Tested on macOS — host sees the Pi as `en*` interface, SSH over USB confirmed
- Pi side: `10.55.0.1/24` on `usb0`
- Mac side: configure with `sudo ifconfig <iface> 10.55.0.2 netmask 255.255.255.0 up`
- Gadget comes up automatically on boot via systemd

## Setup steps so far

1. Raspberry Pi OS Lite 64-bit, headless first boot
2. Added `dtoverlay=dwc2` to `/boot/firmware/config.txt`
3. Added `dwc2` and `libcomposite` to `/etc/modules`
4. `pi-setup/gadget-ethernet.sh` configures the gadget via configfs
5. systemd unit at `pi-setup/systemd/velosterplay-gadget.service` runs the script on boot

## License

MIT. See [LICENSE](LICENSE).
