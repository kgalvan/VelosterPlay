#!/bin/bash
#
# gadget-ethernet.sh — bring up a USB Ethernet gadget for testing.
#
# This is a hello-world to verify USB gadget mode works end-to-end.
# When the Pi is plugged into a host (via the data port, not the
# power port), the host will see a new USB network adapter.
#
# Run as root: sudo ./gadget-ethernet.sh
#

set -e

GADGET_DIR=/sys/kernel/config/usb_gadget/velosterplay-test
UDC_NAME=$(ls /sys/class/udc | head -n1)

if [ -z "$UDC_NAME" ]; then
    echo "ERROR: No UDC available. Is dwc2 loaded?"
    exit 1
fi

echo "Using UDC: $UDC_NAME"

# Clean up any previous gadget with this name
if [ -d "$GADGET_DIR" ]; then
    echo "Removing existing gadget"
    echo "" > "$GADGET_DIR/UDC" 2>/dev/null || true
    find "$GADGET_DIR" -depth -type l -exec rm {} \;
    find "$GADGET_DIR" -depth -type d -empty -delete
fi

# Create the gadget
mkdir -p "$GADGET_DIR"
cd "$GADGET_DIR"

# USB device descriptor — identifies the device to the host
echo 0x1d6b > idVendor    # Linux Foundation (a real VID assigned for gadget testing)
echo 0x0104 > idProduct   # Multifunction Composite Gadget
echo 0x0100 > bcdDevice   # Device version 1.0.0
echo 0x0200 > bcdUSB      # USB 2.0

# Strings shown to the host
mkdir -p strings/0x409    # 0x409 = English (US)
echo "deadbeef00000001"      > strings/0x409/serialnumber
echo "VelosterPlay"          > strings/0x409/manufacturer
echo "VelosterPlay USB Test" > strings/0x409/product

# Configuration — a device can have multiple, we use one
mkdir -p configs/c.1/strings/0x409
echo "Ethernet Config" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower    # in mA

# Function: ECM Ethernet (works with macOS and Linux)
mkdir -p functions/ecm.usb0

# Link the function into the configuration
ln -s functions/ecm.usb0 configs/c.1/

# Activate: write the UDC name to bind the gadget to the controller
echo "$UDC_NAME" > UDC

echo "Gadget bound to $UDC_NAME"

# Configure the host-facing Linux side of the Ethernet link
# (this is the Pi's side of the virtual network connection)
ip addr add 10.55.0.1/24 dev usb0 2>/dev/null || true
ip link set usb0 up

echo "USB Ethernet active. Pi side IP: 10.55.0.1"
