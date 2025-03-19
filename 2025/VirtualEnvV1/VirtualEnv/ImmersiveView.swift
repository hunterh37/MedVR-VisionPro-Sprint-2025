//
//  ImmersiveView.swift
//  VirtualEnv
//
//  Created by Dat Nguyen on 3/13/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in

            if let contentReturn = await appModel.loadImmersiveSpace(
                immersiveSceneName: appModel.immersiveSpaceName.rawValue)
            {
                content.add(contentReturn)
            } else {
                print("Failed to load immersive space.")
            }

        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
