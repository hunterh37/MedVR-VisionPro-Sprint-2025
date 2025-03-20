//
//  ImmersiveView.swift
//  CustomHandGestureSample
//
//  Created by Hunter Harris on 3/19/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/* Global entities */
var rootEntity = Entity()
var floorEntity = ModelEntity()
var leftHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 100)
var rightHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 100)
var rightHandIntermediate = Entity()

var projectileCollisionGroup = CollisionGroup(rawValue: 17)
var handCollisionGroup = CollisionGroup(rawValue: 18)

let targetCollisionName = "target"
let handCollisionName = "hand"

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @ObservedObject var gestureModel: HandGestureModel = HandGestureModelContainer.handGestureModel

    var body: some View {
        RealityView { content in
            content.add(rootEntity)
        }.task {
            await gestureModel.start()
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

