//
//  UpdaterVC.swift
//  
//
//  Created by Michael Berk on 2/14/23.
//

import AppKit

class UpdaterVC: NSViewController {
	
	var updater: Updater!
	@IBOutlet var headlineLabel: NSTextField!
	@IBOutlet var subHeadlineLabel: NSTextField!
	@IBOutlet var imageView: NSImageView!
	var releaseTag: String?
	
	var downloadURL: URL?
	
	init(updater: Updater) {
		super.init(nibName: nil, bundle: Bundle.module)
		self.updater = updater
		loadView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public override func viewDidAppear() {
		super.viewDidAppear()
		//check for updates
	}
	
	public override func viewDidDisappear() {
		super.viewDidDisappear()
		NSApp.stopModal()
	}
	
		
	public override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func showRelease(_ release: GithubRelease) {
		let headline = "A new version of \(Updater.appName) is available!"
		let releaseName = release.name
		let currentReleaseName = "\(Updater.version) (\(Updater.build))"
		let subheadline = "\(releaseName) is now available - you have \(currentReleaseName).\nDo you want to download it?"
		self.headlineLabel.stringValue = headline
		self.headlineLabel.sizeToFit()
		self.subHeadlineLabel.stringValue = subheadline
		self.subHeadlineLabel.sizeToFit()
		self.releaseTag = release.tagName
		let asset = updater.assetsClosure(release.assets)
		self.downloadURL = asset.browserDownloadURL
	}
	
	@IBAction func downloadButtonClicked(_ sender: Any?) {
		guard let downloadURL else {
			let alert = NSAlert()
			alert.messageText = "No Download URL Provided"
			alert.beginSheetModal(for: view.window!)
			return
		}
		NSWorkspace.shared.open(downloadURL, configuration: .init(), completionHandler: { _, _ in
			NSApp.stopModal()
			DispatchQueue.main.async {
				let alert = NSAlert()
				alert.messageText = "Please quit \(Updater.appName) before installing the update."
				alert.beginSheetModal(for: self.view.window!) { _ in
					self.view.window?.close()
				}
			}
		})
	}
	
	@IBAction func dismissButtonClicked(_ sender: Any?) {
		self.view.window?.close()
	}
	
	@IBAction func surpressVersionClicked(_ sender: Any?) {
		if let releaseTag {
			updater.skippedVersions.append(releaseTag)
		}
		self.view.window?.close()
	}
}
