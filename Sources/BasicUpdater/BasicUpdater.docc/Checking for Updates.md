# Checking for Updates

Learn how to check for updates manually, and configure automatic update prompts 

## Manually Checking for Updates

To check for updates manually (such as for a "Check for Updates" button), just call ``Updater/checkForUpdates(showIfLatest:maxReleases:)``. 
```swift
struct MyView: View {
	
	@EnvironmentObject var updater: Updater
	
	var body: some View {
		Button("Check for Updates") {
			updater.checkForUpdates()
		}
	}
}
```


By default, if there's a new version to update to (using the semantics defined above), then it will prompt the user to update. Otherwise, it will display an alert notifying the user that they're on the latest version. See the documentation for more info.

## Configuring Automatic Updates

Out-of-the box, the Updater will check for updates once it's been instantiated. If you don't want this behavior (such as allowing the user to choose whether or not to automatically check), set the ``Updater/autoCheckForUpdates`` accordingly. This state is stored in `UserDefaults` with the ``Updater/autoCheckForUpdatesKey``. By default, the value is stored in the `standard` suite, but you can customize it in through the `userDefaultsSuite` argument in the ``Updater/init(projectURL:userDefaultsSuite:autoCheckByDefault:shouldUpdateTo:assetToUse:)`` initalizer.

If you want auto-checking to be an opt-in behavior, set the `autoCheckByDefault` property to `false` in the ``Updater/init(projectURL:userDefaultsSuite:autoCheckByDefault:shouldUpdateTo:assetToUse:)`` initalizer. 

