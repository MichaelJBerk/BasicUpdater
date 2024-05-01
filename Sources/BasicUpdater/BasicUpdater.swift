import Foundation
import Cocoa
import os

///Object that manages checking and prompting for updates
public class Updater: ObservableObject {
	
	///UserDefaults key for the list of skipped versions
	public static let skippedVersionsKey = "basicUpdaterSkippedVersions"
	
	///UserDefaults key for the auto-update setting
	public static let autoCheckForUpdatesKey = "basicUpdaterAutoCheckForUpdates"
	
	///Whether or not the user should be prompted to update as soon as the object is created
	///
	///This value is stored in UserDefaults with the ``autoCheckForUpdatesKey``. Getting/Setting this value automatically retrieves the current value from UserDefaults, or updates the current value in UserDefaults.
	public var autoCheckForUpdates: Bool {
		get {
			userDefaults.object(forKey: Self.autoCheckForUpdatesKey) as? Bool ?? true
		}
		set {
			userDefaults.set(newValue, forKey: Self.autoCheckForUpdatesKey)
			self.objectWillChange.send()
		}
	}
	
	///Tags of versions that the user has chosen to skip
	///
	///This array is stored in UserDefaults with the ``skippedVersionsKey``. Getting/Setting this value automatically retrieves the current value from UserDefaults, or updates the current value in UserDefaults.
	public var skippedVersions: [String] {
		get {
			return userDefaults.stringArray(forKey: Self.skippedVersionsKey) ?? [String]()
		}
		set {
			userDefaults.set(newValue, forKey: Self.skippedVersionsKey)
			self.objectWillChange.send()
		}
	}
	
	///UserDefaults suite to use
	var userDefaults: UserDefaults!
	
	///URL for the project on Github, such as `https://github.com/michaeljberk/BasicUpdater`, to use when retrieving updates
	var projectURL: URL!
	
	///Closure that defines the semantics of when a user should be prompted to a particular release
	///
	///This is called by the ``shouldUpdateTo`` method. If you need to check if the user should update to a specific release, call that method instead.
	var updateClosure: (GithubRelease) -> Bool
	
	///Closure that defines which asset should be used for the download link.
	///
	///By default, this uses the first asset in the array. It can be overridden in the initalizer.
	var assetsClosure: ([GithubAsset]) -> GithubAsset = { assets in
		return assets.first!
	}
	
	/// Create a new Updater object
	///
	/// If the object's ``autoCheckForUpdates`` property is `true`, it will automatically check for upates after the Updater is initalized.
	///
	/// - Parameters:
	///   - projectURL: URL for the project on GitHub, such as `https://github.com/michaeljberk/BasicUpdater`.
	///   - userDefaultsSuite: Name of custom UserDefaults suite to use for keeping track of ``autoCheckForUpdates`` and ``skippedVersions``. If not specified, the Updater will use `standard`.
	///   - autoCheckByDefault: The default value for the ``autoCheckForUpdates`` property. Defaults to `true`
	///   - shouldUpdateTo: Closure that defines whether or not the user should be prompted to update to a release with a given tag.
	///   - assetToUse: Closure that defines which asset to use. If `nil`, it will use the first release in the array of assets from the release. `nil` by default.
	public init(projectURL: URL!, userDefaultsSuite: String? = nil, autoCheckByDefault: Bool = true, shouldUpdateTo: @escaping (GithubRelease) -> Bool, assetToUse: (([GithubAsset]) -> GithubAsset)? = nil) {
		self.projectURL = projectURL
		self.updateClosure = shouldUpdateTo
		if let assetToUse {
			assetsClosure = assetToUse
		}
		if let userDefaultsSuite {
			self.userDefaults = .init(suiteName: userDefaultsSuite)
		} else {
			self.userDefaults = .standard
		}
		if userDefaults.object(forKey: Self.autoCheckForUpdatesKey) == nil {
			self.autoCheckForUpdates = autoCheckByDefault
		}
		if autoCheckForUpdates {
			checkForUpdates(showIfLatest: false)
		}
	}
	
	/// Create a URL to use to get releases
	///
	/// - Parameter max: The maximum number of releases to request
	/// - Returns: GitHub URL to get releases
	func releaseURL(max: Int) -> URL {
		var comps = URLComponents(url: projectURL, resolvingAgainstBaseURL: false)!
		comps.host = "api.github.com"
		comps.path = "/repos\(comps.path)/releases"
		comps.queryItems = [URLQueryItem]()
		comps.queryItems?.append(.init(name: "per_page", value: "\(max)"))
		return comps.url!
	}
	
	/// Checks GitHub for updates, and prompts the user to update if one is available.
	///
	/// After requesting the list of updates from GitHub, the method calls the `shouldUpdateTo` closure provided in the initializer for each release in the array. Once the method returns `true` for a release, the user is prompted to update to it.
	///
	/// - Parameters:
	///   - showIfLatest: Determines if the app should show an alert if the user is using the most recent version of the app
	///   - maxReleases: Number of GitHub releases to check. Due to GitHub's API, this can't be over 100. Defaults to 1.
	public func checkForUpdates(showIfLatest: Bool = true, maxReleases: Int = 1) {
		Task {
			do {
				let releases = try await getReleases(max: maxReleases)
				var foundUpdate = false
				for release in releases {
					if self.shouldUpdateTo(release: release) == true {
						foundUpdate = true
						await MainActor.run {
							self.showUpdater(for: release)
						}
						break
					}
				}
				if showIfLatest, !foundUpdate {
					await showLatestAlert()
				}
			} catch {
				let errorStr = String(describing: error)
				NSLog("BasicUpdater error: %@", errorStr)
			}
		}
	}
	
	/// Determine if the user should be prompted to update to a particular release.
	/// - Parameter release: Release to check if the user should update to.
	/// - Returns: `true` if the user should be prompted to update to the release, `false` if not.
	func shouldUpdateTo(release: GithubRelease) -> Bool {
		if !skippedVersions.contains(release.tagName) {
			return self.updateClosure(release)
		}
		return false
	}
	
	
	@MainActor
	/// Shows the "App is up-to-date" alert
	private func showLatestAlert() {
		let alert = NSAlert()
		alert.messageText = "\(Updater.appName) is Up-To-Date"
		alert.informativeText = "\(Updater.appName) \(Updater.version) (\(Updater.build)) is the most recent version available."
		alert.alertStyle = .informational
		alert.runModal()
	}
	
	///Version number of the app (`CFBundleShortVersionString`)
	static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
	///Build number of the app (`CFBundleVersion`)
	static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
	///Name of the app (`CFBundleName`)
	static let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
	
	/// Retrieve the list of releases from GitHub
	/// - Parameter max: Maximum number of releases that should be returned by GitHub. The equivalent to the API's `per_page` parameter
	/// - Returns: The list of releases from the GitHub Releases API
	private func getReleases(max: Int) async throws -> [GithubRelease] {
		let url = releaseURL(max: max)
		let data = try await URLSession.shared.data(for: URLRequest(url: url))
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let releases = try decoder.decode([GithubRelease].self, from: data.0)
		return releases
	}
	
	
	/// Show the prompt for the user to update
	/// - Parameter release: Release to prompt the user to update to
	private func showUpdater(for release: GithubRelease) {
		let vc = UpdaterVC(updater: self)
		vc.showRelease(release)
		let window = NSWindow(contentViewController: vc)
		window.title = "Update"
		window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
		window.standardWindowButton(.zoomButton)?.isEnabled = false
		window.styleMask.remove(.resizable)
		window.animationBehavior = .alertPanel
		NSApp.runModal(for: window)
	}
	
}
