# Keychain

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
Use `Keychain` in order to store eider passowrds or certificates

### Certificates 

```swift
public static func storeCertificate(_ data: Data, for key: String, dependencies: Dependencies) throws 

public static func deleteCertificate(for key: String, dependencies: Dependencies) throws 

public static func fetchCertificate(for key: String, dependencies: Dependencies) throws -> Data? 
```

### Passwords 

```swift
public static func storePassword(_ data: Data, for key: String, dependencies: Dependencies) throws 

public static func deletePassword(for key: String, dependencies: Dependencies) throws 

public static func fetchPassword(for key: String, dependencies: Dependencies) throws -> Data?
```
