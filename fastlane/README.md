# Fastlane Swift

In this project we use Fastlane swift as our choice of setup. You might be wondering why we use swift for a ruby program and the only reason is to make it more accessible to our iOS developers. Only a few to none iOS developer are familiar with Ruby and that can cause more damage than good. By using swift we are enable those developers to better understand our CI / CD scripts and help themself when something happens.

_Important Note_

Fastlane.swift is still in beta. You can find out more here: [https://docs.fastlane.tools/getting-started/ios/fastlane-swift/#getting-started-with-fastlaneswift-beta](https://docs.fastlane.tools/getting-started/ios/fastlane-swift/#getting-started-with-fastlaneswift-beta)

## Available Actions

```
fastlane buildAndTest root_path:Source/CovPassCommon path:Sources,Tests scheme:CovPassCommon coverage:10.0
```

```
fastlane unitTest root_path:Source/CovPassCommon scheme:CovPassCommon
```

```
fastlane lint root_path:Source/CovPassCommon path:Sources,Tests
```

```
fastlane codeCoverage root_path:Source/CovPassCommon scheme:CovPassCommon coverage:10.0
```

## Developer Note

You're welcome to extend the library as needed. Please make sure that you test all you changes on your local machine before pushing those changes to the master. When creating new lanes, keep those lanes as general as possible. Please do not create lanes just for one specific project in this repository. This will lead to unreadable and unmaintainable code.

To update Fastlane, open the project located at `fastlane/swift/FastlaneSwiftRunner/FastlaneSwiftRunner.xcodeproj`. Please do not delete or modify the generated files. This could cause fastlane to fail to produce sudden errors. The file where everything is located and you can edit is called `Fastfile`.
