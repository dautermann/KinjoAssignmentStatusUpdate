//
//  ContentView.swift
//  Shared
//
//  Created by Michael Dautermann on 6/13/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: UpdateManager

    var body: some View {
        VStack {
            Spacer()

            TextEditor(text: $viewModel.stringToDisplay)
                .foregroundColor(.secondary)
            Button("Kinjo Doc 2") {
                viewModel.loadKinjoFile(filename: "Kinjo Doc 2.csv")
            }
            Button("Kinjo Doc 3") {
                viewModel.loadKinjoFile(filename: "Kinjo Doc 3.csv")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: UpdateManager())
    }
}
