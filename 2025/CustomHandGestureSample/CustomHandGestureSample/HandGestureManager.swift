//
//  HandGestureManager.swift
//  CustomHandGestureSample
//
//  Created by Hunter Harris on 3/19/25.
//

#if targetEnvironment(simulator)
import ARKit
#else
@preconcurrency import ARKit
#endif
import RealityKit
import SwiftUI
import simd

@MainActor
enum HandGestureModelContainer {
    private(set) static var handGestureModel = HandGestureModel()
}


@MainActor
class HandGestureModel: ObservableObject, @unchecked Sendable {
    let session = ARKitSession()
    var handTracking = HandTrackingProvider()
    @Published var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    
    var nextActionTime = Date()
    var actionDelayTime: TimeInterval = 0.3 // delay between actions
    var minimumGestureDistance = 0.09
    
    struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
    
    func start() async {
        do {
            // leftHandEntity = try await ModelEntity(named: "leftHand")
            rightHandEntity = try await ModelEntity(named: "Syringe")
            leftHandEntity.scale = .init(repeating: 0.13)
            rightHandEntity.scale = .init(repeating: 0.06)
        } catch { }
        
        rightHandIntermediate.addChild(rightHandEntity)
        rootEntity.addChild(rightHandIntermediate)
        
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
                await publishHandTrackingUpdates()
            } else {
                
            }
        } catch { }
    }

    
    func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                let anchor = update.anchor
                guard anchor.isTracked else { continue }
                
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                    leftHandEntity.transform = Transform(matrix: anchor.originFromAnchorTransform)
                    leftHandEntity.scale = .init(repeating: 0.13) 
                } else if anchor.chirality == .right {
                    latestHandTracking.right = anchor
                    rightHandIntermediate.transform = Transform(matrix: anchor.originFromAnchorTransform)
                    
                    checkIfPerformingGunShootGesture(update: update)
                }
                
            default:  break
            }
        }
    }
    
    func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(let type, let status):
                if type == .handTracking && status != .allowed {
                    
                }
            case .dataProviderStateChanged(dataProviders: let dataProviders, newState: let newState, error: _):
                print("Data provide state changed: \(dataProviders.count) - \(newState.description)")
            @unknown default:
                print("Session event \(event)")
            }
        }
    }
}

extension HandGestureModel {
    private func configureHandCollision() {
        var collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.214)])
        collision.filter = CollisionFilter(group: handCollisionGroup, mask: [projectileCollisionGroup])
        collision.mode = .default
        
        leftHandEntity.name = handCollisionName
        leftHandEntity.collision = collision
        leftHandEntity.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default, material: nil,  mode: .kinematic)
        
        rightHandEntity.name = handCollisionName
        rightHandEntity.collision = collision
        rightHandEntity.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default, material: nil,  mode: .kinematic)
    }
    
    /// Compute if is making finger gun trigger action, based on received HandAnchor update
    func checkIfPerformingGunShootGesture(update: AnchorUpdate<HandAnchor>) {
        Task(priority: .low) {
            guard let indexFinger = update.anchor.handSkeleton?.joint(.indexFingerTip),
                  let thumbTip = update.anchor.handSkeleton?.joint(.indexFingerMetacarpal) else {
                return
            }
            let indexFingerPos = matrix_multiply(update.anchor.originFromAnchorTransform, indexFinger.anchorFromJointTransform).translation
            let thumbTipPos = matrix_multiply(update.anchor.originFromAnchorTransform, thumbTip.anchorFromJointTransform).translation
            
            let currentFingertipShootDistance = simd_distance(indexFingerPos, thumbTipPos)//thumbTipPos - indexFingerPos
            
            print("shoot gesture distance: \(currentFingertipShootDistance)")
            
            // Trigger the gun shoot action if user thumbtip - indexfinger is close enough
            // to mimic finger gun action 'pulling trigger'
            if currentFingertipShootDistance < Float(minimumGestureDistance) {
                let now = Date()
                guard now > nextActionTime else { return }
                
                nextActionTime = now + actionDelayTime
            }
        }
    }
    
    func getPositionInFrontOfGun(distance: Float) -> SIMD3<Float> {
        let handTransform = rightHandIntermediate.transform
        var forwardDirection = simd_normalize(handTransform.matrix.columns.0.xyz)
        forwardDirection = forwardDirection * -1

        let finalPosition = handTransform.translation + (forwardDirection * distance)
        return finalPosition
    }
}


/// Extension for float4x4 -> SIMD3 translation
extension float4x4 {
    var translation: SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
    init(translation vector: SIMD3<Float>) {
        self.init(.init(1, 0, 0, 0),
                  .init(0, 1, 0, 0),
                  .init(0, 0, 1, 0),
                  .init(vector.x, vector.y, vector.z, 1))
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        SIMD3(x, y, z)
    }
}


extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}

