//
//  AppModel.swift
//  MedicalToolsSample
//
//  Created by Hunter Harris on 3/19/25.
//

import SwiftUI
import RealityFoundation

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    func spawnFloor() {
        var material = SimpleMaterial(color: .clear, isMetallic: false)
        material.color = .init(tint: .clear.withAlphaComponent(0.0001))
        floorEntity = ModelEntity(mesh: .generateBox(width: 30, height: 1, depth: 20), materials: [material], collisionShape: .generateBox(width: 30, height: 1, depth: 20), mass: 100000)
        floorEntity.components[PhysicsBodyComponent.self] = .init(massProperties: .init(mass: 100000), material: .default,  mode: .static)
        
        var collision = CollisionComponent(shapes: [ .generateBox(width: 30, height: 1, depth: 20)])
        collision.mode = .default
        floorEntity.components[CollisionComponent.self] = collision
        
        floorEntity.position = .init(x: 0, y: -0.5, z: 0)
        rootEntity.addChild(floorEntity)
    }
    
    func spawnStartingScene() async {
        do {
            // Load the ChariteUniversity_OperatingRoomScan model
            let loadingOperatingRoomModel = try await ModelEntity(named: "ChariteUniversity_OperatingRoomScan")
            operatingRoomModel = loadingOperatingRoomModel
            rootEntity.addChild(operatingRoomModel)
            
            // Load the syringe model
            let loadedSyringeModel = try await ModelEntity(named: "Syringe")
            syringeModel = loadedSyringeModel
            syringeModel.position = .init(x: 0.4, y: 0.3, z: 0) // set a custom position, move it over a bit
            syringeModel.configureGestures()
            syringeModel.configurePhysics()
            rootEntity.addChild(syringeModel)
            
            // Load the doctors stool model
            let loadedDotorsStoolModel = try await ModelEntity(named: "Doctors_Stool")
            doctorsStoolModel = loadedDotorsStoolModel
            doctorsStoolModel.position = .init(x: 0.4, y: 0.1, z: 0.3)
            doctorsStoolModel.configureGestures()
            doctorsStoolModel.configurePhysics()
            rootEntity.addChild(doctorsStoolModel)
            
            // Load the heart rate model
            let loadedHeartRateModel = try await ModelEntity(named: "HeartRateMonitor")
            heartRateModel = loadedHeartRateModel
            heartRateModel.position = .init(x: 0.4, y: 0.1, z: -0.2)
            heartRateModel.configureGestures()
            heartRateModel.configurePhysics()
            rootEntity.addChild(heartRateModel)
            
            // Load the medical scissors model
            let loadedMedicalScissorsModel = try await ModelEntity(named: "MedicalScissors")
            medicalScissorsModel = loadedMedicalScissorsModel
            medicalScissorsModel.scale = .init(repeating: 0.1)
            medicalScissorsModel.position = .init(x: 0.4, y: 0.3, z: -0.2)
            medicalScissorsModel.configureGestures()
            medicalScissorsModel.configurePhysics()
            rootEntity.addChild(medicalScissorsModel)
        } catch { }
    }
}
