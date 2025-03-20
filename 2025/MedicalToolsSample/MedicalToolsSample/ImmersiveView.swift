//
//  ImmersiveView.swift
//  MedicalToolsSample
//
//  Created by Hunter Harris on 3/19/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

/* Global entities */
let rootEntity = Entity()
var floorEntity = Entity()
var operatingRoomModel = ModelEntity()
var syringeModel = ModelEntity()
var doctorsStoolModel = ModelEntity()
var heartRateModel = ModelEntity()
var medicalScissorsModel = ModelEntity()
var surgicalMaskModel = ModelEntity()

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            content.add(rootEntity)
            appModel.spawnFloor()
            await appModel.spawnStartingScene()
        }
        .gesture(dragGesture)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in // When drag begins/changes, set Rigidbody to kinematic
                guard let parent = value.entity.parent else { return }
                value.entity.position = value.convert(value.location3D, from: .local, to: parent)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
                
                print("value position:\(value.entity.position)")
            }
            .onEnded({ value in // When drag ends, set Rigidbody back to dynamic
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                
                
            })
    }
}

extension Entity {
    func configureGestures() {
        self.components.set(InputTargetComponent())
        self.generateCollisionShapes(recursive: true)
    }
    
    func configurePhysics() {
        self.components.set(PhysicsBodyComponent(mode: .dynamic))
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
