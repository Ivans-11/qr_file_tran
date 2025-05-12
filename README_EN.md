<div align="center">
  <img src="assets/logo.png" alt="QR-Link Logo" width="200"/>
</div>

English | [中文](README.md)

# QR-Link

A Flutter-based file transfer application that enables offline file transfer between devices using QR codes. Currently supports Android platform only.

## Getting Started

### Method 1: Direct APK Installation

1. Download the latest APK file from [Releases](https://github.com/Ivans-11/qr_file_tran/releases)
2. Install the APK file on your Android device
3. Make sure to grant all necessary permissions when first launching the app

### Method 2: Build from Source

1. Ensure you have Flutter development environment installed
2. Clone the repository
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Usage Guide

1. Sending Files:
   - Click the "Select File" button to choose files or folders to transfer
   - The system will automatically process the files and generate QR code sequences
   - The receiver can scan the QR codes to receive the files

2. Receiving Files:
   - Click the "Scan" button and enter the verification code
   - Use the camera to scan the QR codes displayed by the sender
   - Files will be automatically saved to device storage

## Required Permissions

The app requires the following permissions:
- Storage permission: for reading and saving files
- Camera permission: for scanning QR codes

## Notes

- Currently only supports Android platform
- Recommended for Android 10 and above
- Make sure to grant all necessary permissions on first use 