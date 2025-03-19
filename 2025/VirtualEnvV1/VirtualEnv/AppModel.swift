//
//  AppModel.swift
//  VirtualEnv
//
//  Created by Dat Nguyen on 3/13/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    enum immersiveSpaceString:String {
       case CUH_OR = "Room/CUH_OR"
       case OR_Blue = "Room/OR_Blue"
       case OR_Small = "Room/OR_Small"
    }
    
    
    var rootEntity: Entity = Entity()
    var modelStore: [String: ModelEntity] = [:]
    let immersiveSpaceID = "ImmersiveSpace"
    var immersiveSpaceName = immersiveSpaceString.CUH_OR
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    func loadModelEntity(
        name: String,
        position: SIMD3<Float> = SIMD3<Float>(0,0,0)
    ) async {
        if let loadModel = try? await ModelEntity(named: name) {
            print("load model entity successfully:\(name)")
            loadModel.setPosition(position, relativeTo: nil)
            modelStore[name] = loadModel
            rootEntity.addChild(loadModel)
        } else {
            print("unable to load model: \(name)")
        }
    }
    
    func loadImmersiveSpace(immersiveSceneName: String) async -> Entity? {
        guard let immersiveContentEntity = try? await Entity(
            named: immersiveSceneName,
            in: realityKitContentBundle
        ) else { return nil }
        return immersiveContentEntity
    }
}
