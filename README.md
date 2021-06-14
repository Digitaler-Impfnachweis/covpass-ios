# [iOS] CovPass & CovPass Check
<br />
<p align="center">
  <a href="#">
    <img src="Source/CovPassApp/Source/Resources/Assets.xcassets/AppIcon.appiconset/80.png" alt="Logo" width="80" height="80">
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

Before you build the project, you need to copy the configuration files with `./copy-config-files.sh` and the parameter `debug`, or `release`. The configuration files contain public key, TLS certificate, and the initial DSC file.

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

* 1.3.0
    * Add recovery and test certificates
    * Add new detail view to list all different types of certificates
    * Check for extendedKeyUsage Oids
    * Bugfixes and smaller adjustments
* 1.2.0
    * Adjust DGC scheme validation for <= 1.1.0
* 1.1.2
    * UI Adjustments
* 1.1.1
    * Initial Project