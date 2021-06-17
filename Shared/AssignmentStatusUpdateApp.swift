//
//  AssignmentStatusUpdateApp.swift
//  Shared
//
//  Created by Michael Dautermann on 6/13/21.
//

import SwiftUI

@main
struct AssignmentStatusUpdateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: UpdateManager())
        }
    }
}
