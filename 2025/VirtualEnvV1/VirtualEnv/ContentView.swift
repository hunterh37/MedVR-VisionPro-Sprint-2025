//
//  ContentView.swift
//  VirtualEnv
//
//  Created by Dat Nguyen on 3/13/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 20)

            Text("Hello, Space!").padding(.bottom, 20)

            ToggleISButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
