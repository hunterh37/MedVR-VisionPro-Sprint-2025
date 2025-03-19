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
var operatingRoomModel = ModelEntity()
var syringeModel = ModelEntity()
var doctorsStoolModel = ModelEntity()

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            content.add(rootEntity) // Add rootEntity to the scene
            
            Task {
                // Load the ChariteUniversity_OperatingRoomScan model
                let loadingOperatingRoomModel = try await ModelEntity(named: "ChariteUniversity_OperatingRoomScan")
                operatingRoomModel = loadingOperatingRoomModel
                rootEntity.addChild(operatingRoomModel)
                
                // Load the sytinge model
                let loadedSyringeModel = try await ModelEntity(named: "Syringe")
                syringeModel = loadedSyringeModel
                syringeModel.position = .init(x: 0.4, y: 0.3, z: 0) // set a custom position, move it over a bit
                syringeModel.components.set(InputTargetComponent()) // needed for drag gesture
                syringeModel.generateCollisionShapes(recursive: true) // needed for drag gesture
                rootEntity.addChild(syringeModel)
                
                // Load the doctors stool model
                let loadedDotorsStoolModel = try await ModelEntity(named: "Doctors_Chair")
                doctorsStoolModel = loadedDotorsStoolModel
                doctorsStoolModel.position = .init(x: 0.4, y: 0.3, z: 0.3) 
                doctorsStoolModel.components.set(InputTargetComponent())
                doctorsStoolModel.generateCollisionShapes(recursive: true)
                rootEntity.addChild(doctorsStoolModel)
            }
        }
        .gesture(dragGesture)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let parent = value.entity.parent else { return }
                value.entity.position = value.convert(value.location3D, from: .local, to: parent)
            }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
