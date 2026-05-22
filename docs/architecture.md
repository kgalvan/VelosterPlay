# Architecture

This document captures the mental model of how VelosterPlay works. Update it as understanding evolves.

## The four jobs the Pi does simultaneously

1. **USB Device Impersonation** — present as a CarPlay-capable Apple accessory to the Hyundai head unit, over USB gadget mode.
2. **BLE Advertisement** — broadcast wireless CarPlay availability to the iPhone using the specific GATT services and advertisement data Apple expects.
3. **Wi-Fi Transport** — establish a Wi-Fi link with the iPhone (either Pi-as-AP or joining iPhone's network) for the actual A/V streams.
4. **Bridging** — proxy A/V from iPhone-over-Wi-Fi into the USB stream to the head unit, and proxy touch/control events back the other way.

## Why the head unit can't tell

From the head unit's perspective, nothing changes. It sees a wired CarPlay device on USB, does its normal iAP2 handshake, validates with its MFi coprocessor against the iPhone, and starts streaming. The wireless layer is invisible to it — that's the entire trick.

## What we are NOT doing

- Bypassing MFi authentication. The head unit's existing MFi chip handles auth, and we transparently relay challenge/response.
- Modifying head unit firmware (in Phase 1 — that's Phase 2+).
- Reimplementing CarPlay from scratch. We're using node-CarPlay as the foundation and adding the wireless front-end.

## Components

### USB gadget side

Linux's `libcomposite` + configfs lets us define arbitrary USB device descriptors at runtime. We configure the Pi to expose the interfaces a wired CarPlay device would: USB Audio, USB HID, and an iAP2 vendor-specific interface for the control channel.

### iAP2 / CarPlay session

node-CarPlay handles the protocol — the handshake, the H.264 video frames, the audio streams, the touch event encoding. We instantiate it on the Pi side and feed/drain its data streams.

### BLE advertisement

iPhones discover wireless CarPlay accessories via specific BLE advertisement data. BlueZ on the Pi crafts and broadcasts these.

### Wi-Fi handover

After BLE pairing, iPhone negotiates a Wi-Fi transport. Implementation pattern (TBD which we use):
- Pi hosts an AP with hostapd, iPhone joins
- Pi and iPhone use Wi-Fi Direct
- iPhone hosts a personal hotspot, Pi joins

The dongles do the AP-hosting variant. We'll likely match.

## Open questions

- Exact BLE advertisement format Apple expects (see node-CarPlay source and Carlinkit traffic captures).
- Whether the head unit's iAP2 implementation has quirks beyond stock spec.
- Power management — can the Pi boot fast enough for the head unit to consider it "ready" at car-on?