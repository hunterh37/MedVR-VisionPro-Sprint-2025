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

var collisionEntity = ModelEntity()

var leftHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 0)
var rightHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 0)
var rightHandIntermediate = Entity()

var triggerEntityName = "triggerEntity"
var collisionEntityName = "collisionEntity"

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @ObservedObject var gestureModel: HandGestureModel = HandGestureModelContainer.handGestureModel
    @State private var collisionSubscription: EventSubscription?
    
    var body: some View {
        RealityView { content in
            rootEntity = Entity()
            content.add(rootEntity)
            
            // Configure collision entity
            collisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.3), materials: [UnlitMaterial(color: .yellow)], collisionShape: .generateSphere(radius: 0.3), mass: 100)
            collisionEntity.generateCollisionShapes(recursive: true)
            collisionEntity.name = "collisionEntity"
            rootEntity.addChild(collisionEntity)
            
            subscribeToCollisionEvents(content: content)
        }.task {
            await gestureModel.start()
        }
        .upperLimbVisibility(.hidden)
    }
    
    func subscribeToCollisionEvents(content: RealityViewContent) {
        collisionSubscription = content.subscribe(to: CollisionEvents.Began.self) { event in
            
            if event.entityA.name == triggerEntityName,
               event.entityB.name == collisionEntityName {
                // Trigger entity has collided with collisionEntity,
                // perform your custom collision logic here
            }
            
            if event.entityB.name == triggerEntityName,
               event.entityA.name == collisionEntityName {
                // Trigger entity has collided with collisionEntity,
                // perform your custom collision logic here
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
