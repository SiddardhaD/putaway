# Zebra Scanner Integration Guide

## Overview

The app now supports both camera-based scanning (for regular mobile devices) and Zebra DataWedge hardware scanning (for Zebra scanner guns). The barcode scanner widget automatically detects the device type and uses the appropriate scanning method.

## How It Works

### Automatic Detection
When the scanner screen opens, the app automatically:
1. Checks if the device is Android
2. Tries to initialize Zebra DataWedge
3. If DataWedge is available → Uses hardware scanner
4. If DataWedge is not available → Falls back to camera scanner

### For Regular Mobile Devices
- Opens camera view
- User points camera at barcode
- Automatically scans and closes

### For Zebra Scanner Guns
- Shows "Zebra Scanner Ready" screen with a green badge
- User presses the physical trigger button on the Zebra device
- Scanner reads the barcode through the hardware scanner
- Automatically processes and closes

## DataWedge Configuration

The app creates a DataWedge profile named `PutawayApp` automatically when first launched on a Zebra device. This profile is configured to:
- Listen to scan events
- Send scan results to the app
- Work with the app package `com.example.putaway`

## Package Used

- **flutter_datawedge** (v2.1.0): Official Zebra DataWedge integration for Flutter
- **mobile_scanner** (v5.2.3): Camera-based barcode scanning for regular devices

## Testing

### On Regular Mobile Devices
- Tap the QR code icon in any search field
- Camera will open
- Point at a barcode to scan

### On Zebra Scanner Guns
- Tap the QR code icon in any search field
- "Zebra Scanner Ready" screen will appear with a green "Zebra" badge
- Press the physical trigger button on the device
- Barcode will be scanned and processed

## Technical Details

### DataWedge Profile
- **Profile Name**: PutawayApp
- **Package**: com.example.putaway
- **Auto-created**: Yes (on first app launch)

### Error Handling
If DataWedge initialization fails on a Zebra device, the app will automatically fall back to camera scanning to ensure the app remains functional.

## Supported Barcode Types

Zebra DataWedge supports all standard barcode types including:
- QR Code
- Code 128
- Code 39
- EAN-13
- UPC-A
- Data Matrix
- PDF417
- And many more

The exact supported types depend on the Zebra device model and DataWedge configuration.

## Troubleshooting

### Scanner Not Working on Zebra Device
1. Check if DataWedge is installed (pre-installed on all Zebra devices)
2. Ensure the app has necessary permissions
3. Check if another app is using the scanner exclusively
4. Try disabling and re-enabling the scanner in DataWedge settings

### Falls Back to Camera on Zebra Device
This usually means:
- DataWedge is not available or disabled
- The app couldn't create the profile (permissions issue)
- The device doesn't support DataWedge

### No Response When Pressing Trigger
- Make sure the scanner is enabled in DataWedge
- Check if the correct profile is active
- Verify the app is in foreground
