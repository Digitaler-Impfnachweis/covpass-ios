# QRScanner

## Development Setup

1. Run project:
  1. `cd <project-folder>`
  2. `open Package.script`
2. Open the generated xcodeproject.

## Usage

`QRScanner` uses the official SwiftPM manifest format for specifying dependencies. So in order to add a dependency, you will need to do two things:

1. Add a `.package` entry to the `dependencies` array of your `Package`
2. Add all scheme/library names you want to build to the `dependencies` section of the appropriate target(s)

```swift
dependencies: [
    .package(url: "https://github.com/IBM/ios-scanner", from: "0.1.0"),
]

```

Create an instance of `ScannerViewController` that is backed up by certain `.storyboard` or  `.xib`. 
Create an instance of `ScannerCoordinator` then implement `ScannerDelegate` and set it as `.delegate` for previously created   `ScannerCoordinator`.  Delegate medtod `result` will be called whenever certain `QR` has been scanned. 
Previously created `ScannerCoordinator` should be assigned to `coordindator`  variable under  `ScannerViewController`.
`ScannerDelegate` `result` method returns a `Result<String, ScanError>`

Important: iOS requires you to add the "Privacy - Camera Usage Description" key to your Info.plist file, providing a reason for why you want to access the camera.

