//
//  ContentView.swift
//  RealityViewAttachmentSample
//
//  Created by Hunter Harris on 3/25/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
