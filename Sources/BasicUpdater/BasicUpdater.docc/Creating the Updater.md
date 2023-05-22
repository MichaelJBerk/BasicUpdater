# Creating the Updater

Create the `Updater` object, determine whether a new version is available, and choose which asset to use.

## Setting up the Updater

To start, you'll need to create the Updater object. It requires the GitHub URL for your project, and a closure. We'll look at the closure in the next section.

The recommended approach is to create the Updater as a static variable in the `NSApplicationDelegate` for an AppKit app:

```swift
class AppDelegate: NSObject, NSApplicationDelegate {

	//...

	static let updater = Updater(...)

	//...

}
```
...or as a variable in the `App` struct in a SwiftUI app.

```swift
struct MyCoolApp: App {
	
	//...

	static let updater = Updater(...)

	//...
}
```
Take a look at the documentation for ``Updater/init(projectURL:userDefaultsSuite:autoCheckByDefault:shouldUpdateTo:assetToUse:)`` to see the specifics of how to initalize the Updater.

To access the Updater object from a view, you can either call the static variable, or pass the updater as an `EnvironmentObject` in SwiftUI.  


## Determining if the User Should Update to a Release

In order to determine if the user should be prompted to update to a given version, BasicUpdater uses a closure provided in the ``Updater/init(projectURL:userDefaultsSuite:autoCheckByDefault:shouldUpdateTo:assetToUse:)`` initalizer which recieves a ``GithubRelease`` as input, and returns a Boolean value determining whether or not the user should be prompted to update to that release. Use this to define whaterver criteria is needed for a given release to be considered "newer" than the current version the being used. For example, you can use Regex on ``GithubRelease/tagName`` to get the build number, and if it's greater than the current one, return `true`: 

```swift
let updater = Updater(projectURL: ..., shouldUpdateTo: { release in
	//Example: `release.tagName` is "5.0.3-307"
	let regexStr = #"\d*$"#
	let tag = release.tagName
	let range = tag.range(of: regexStr, options: .regularExpression)!
	let newBuildStr = String(tag[range])
	let newBuildNum = Int(newBuildStr)!
	let currentBuildStr = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
	let currentBuildNum = Int(currentBuildStr)!
	return newBuildNum > currentBuildNum
})
```

## Determining Which Asset to Use

By default, the Updater will use the ``GithubAsset/browserDownloadURL`` from the first asset in a given ``GithubRelease``. This can be customized by using the `assetToUse` closure in the ``Updater/init(projectURL:userDefaultsSuite:autoCheckByDefault:shouldUpdateTo:assetToUse:)`` initalizer.

```swift
let updater = Updater(projectURL: ..., shouldUpdateTo: { release in
	//...
},  assetToUse: { assets in
	return assets.first!
})

```
