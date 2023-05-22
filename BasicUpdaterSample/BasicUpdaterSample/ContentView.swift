//
//  ContentView.swift
//  BasicUpdaterSample
//
//  Created by Michael Berk on 2/14/23.
//

import SwiftUI
import BasicUpdater

struct ContentView: View {
	@EnvironmentObject var updater: Updater
	@State var selectedVersion: String? = nil
	
    var body: some View {
		Form {
			Section {
				Toggle("Automatically Check for Updates", isOn: .init(get: {
					updater.autoCheckForUpdates
				}, set: {
					updater.autoCheckForUpdates = $0
				}))
				Button("Check for Updates") {
					updater.checkForUpdates()
				}
			}
			Section("Skipped Versions") {
				List(selection: $selectedVersion) {
					ForEach(updater.skippedVersions, id:\.self) { version in
						Text(version)
					}
					.onDelete { indexSet in
						updater.skippedVersions.remove(atOffsets: indexSet)
					}
				}
				HStack {
					Spacer()
					Button(action: {
						if let selectedVersion, let selectedIndex = updater.skippedVersions.firstIndex(of: selectedVersion) {
							updater.skippedVersions.remove(at: selectedIndex)
						}
					}, label: {
						Image(systemName: "minus")
					})
					.controlSize(.small)
					.disabled(selectedVersion == nil)
				}
			}
		}
		.formStyle(.grouped)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
			.environmentObject(Updater.makeUpdater())
    }
}
