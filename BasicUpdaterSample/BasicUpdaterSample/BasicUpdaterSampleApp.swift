//
//  BasicUpdaterSampleApp.swift
//  BasicUpdaterSample
//
//  Created by Michael Berk on 2/14/23.
//

import SwiftUI
import BasicUpdater

extension Updater {
	static func makeUpdater() -> Updater {
		return Updater(projectURL: .init(string: "https://github.com/MichaelJBerk/Splitter")!, shouldUpdateTo: { _ in
			return true
		})
	}
}

@main
struct BasicUpdaterSampleApp: App {
	
	let updater = Updater.makeUpdater()

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(updater)
        }
    }
}
