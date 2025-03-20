//
//  MedicalToolsSampleApp.swift
//  MedicalToolsSample
//
//  Created by Hunter Harris on 3/19/25.
//

import SwiftUI

@main
struct MedicalToolsSampleApp: App {
    
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

/*
 Attributions:
 
 - Operating room scan:
 https://sketchfab.com/3d-models/charite-university-hospital-operating-room-9ec46c4d615a4581a235eebfb162f574
 
 - Heart rate model: https://sketchfab.com/3d-models/monitor-with-heart-rate-2ef959da5773478383bc46e3bcbc3e8a#download
 
 - Medical scissors:
    https://sketchfab.com/3d-models/medical-scissors-1-38885408402e4a368053de6961fe59a1#download
 
 - Surgical mask:
    https://sketchfab.com/3d-models/surgical-mask-9a0166cd649a4d76bde85fc0ae755dfa#download
 
 - Surgical knife:
    https://sketchfab.com/3d-models/surgical-knife-b435ebe4ea684b75b73008d497a4b082
 
 - Surgical table:
    https://sketchfab.com/3d-models/surgical-instrument-table-collection-a1fcfeab1ad646638089655e8b6f0e2b#download
 
 - Medical monitor:
    https://sketchfab.com/3d-models/medical-monitor-84aa2c97829b4557bc077e8006d97e58#download
 */
