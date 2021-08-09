<h2 align="center">CovPass / CovPass Check</h2>
<br />
<p align="center">
  <a href="#">
    <img src="Resources/CovPass.png" alt="CovPass Icon" width="80" height="80">
  </a>
  <p align="center">
    <b>Einfach. Sicher. Papierlos.</b><br>
    Mit der CovPass-App können Bürgerinnen und Bürger ihre Corona-Impfungen direkt auf das Smartphone laden und mit dem QR-Code belegen
  </p>
</p>

## Requirements

- iOS 12.0 or later
- Xcode 12 or later

## Installation

### Configuration

Before you build the project, you need to copy the configuration files with `./Scripts/copy-config-files.sh` and the parameter `debug`, or `release`. The configuration files contain public key, TLS certificate, and the initial DSC file.

## Application

### CovPass

CovPass contains the app project for the CovPass app.

### CovPassCheck

CovPassCheck contains the app project for the CovPassCheck app.

### CovPassUI

CovPassUI is the UI package for both apps and contains common UI components and flows, like the onboarding screens.

### CovPassCommon

CovPassCommon contains the business logic for both apps, like QR code parsing, signature validation, and persistence.

API documentation TBD

## Release History

- 1.7.0
  - Show invalid and expired certificates
  - PDF export for German certificates
  - Show EU rule country list in alphabetical order
  - Bugfixes
- 1.6.0
  - Add EU business rules for CovPass and CovPassCheck
  - Hide favorite icon with only one certificate
  - English translation for CovPass and CovPassCheck
  - Bugfixes
- 1.4.1
  - Add contact for pass and check app
  - Change certificate matching for certificates with the same family name
  - Adjust card layout for small devices
  - Change keychain properties to support devices without passcode
  - Show hint for devices without passcode
  - Change camera usage description
  - Update app icon
- 1.4.0
  - Add static German rules for certificates
  - Adjust date of birth to support custom format
  - Bugfixes
- 1.3.0
  - Add recovery and test certificates
  - Add new detail view to list all different types of certificates
  - Check for extendedKeyUsage Oids
  - Bugfixes and smaller adjustments
- 1.1.4
  - Remove schema version check to support more certificates from other countries
- 1.1.3
  - Update initial dgc.json list
  - Update date parser to allow different formats
- 1.1.2
  - UI Adjustments
- 1.1.1
  - Initial Project
