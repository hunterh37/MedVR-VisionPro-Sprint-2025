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
            // Load the Syringe 3d model to rightHandEntity
            rightHandEntity = try await ModelEntity(named: "Syringe")
            // Add rightHandEntity as a child to rightHandEntity
            rightHandIntermediate.addChild(rightHandEntity)
            
            // Configure collision on the Syringe entity
            rightHandEntity.name = triggerEntityName
            rightHandEntity.components.set(CollisionComponent(shapes: [.generateBox(width: 0.1, height: 0.1, depth: 0.1)]))
            rightHandEntity.components.set(PhysicsBodyComponent(shapes: [.generateBox(size: .init(x: 0.1, y: 0.1, z: 0.1))], mass: 10))
            
            // Add the rightHandIntermediate to the scene
            rootEntity.addChild(rightHandIntermediate)
            
            rootEntity.addChild(leftHandEntity)
        } catch { }
        
        // Start the hand tracking session and await anchor updates
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
                await publishHandTrackingUpdates()
            } else { }
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
                    
                    // Update the rightHandIntermediate position to the last received right hand anchor update
                    rightHandIntermediate.transform = Transform(matrix: anchor.originFromAnchorTransform)
                    rightHandIntermediate.scale = .init(repeating: 1)
                    
                    // Apply a custom offset to the syringe so its held in hand
                    configureSyringeEntityHandOffset()
                    
                    // Check for custom gestures
                    checkIfPerformingGesture(update: update)
                }
                
            default:  break
            }
        }
    }
    
    /// Applies a custom rotation + position offset so the syringe entity appears
    /// as if it's being held in your right hand.
    func configureSyringeEntityHandOffset() {
       // rightHandIntermediate.transform.applyRotation(degrees: -40, around: SIMD3<Float>(1, 0, 0))
       // rightHandIntermediate.transform.applyRotation(degrees: 180, around: SIMD3<Float>(0, 1, 0))
        let adjustment = SIMD3<Float>(-0.12, -0.0596, 0.02)
        rightHandEntity.position = adjustment
    }
}

extension HandGestureModel {
    private func configureHandCollision() {
        var collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.214)])
        collision.mode = .default
        
        leftHandEntity.collision = collision
        leftHandEntity.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default, material: nil,  mode: .kinematic)
        
        rightHandEntity.collision = collision
        rightHandEntity.components[PhysicsBodyComponent.self] = .init(
            massProperties: .default, material: nil,  mode: .kinematic)
    }
    
    /// Compute if is making finger gun trigger action, based on received HandAnchor update
    func checkIfPerformingGesture(update: AnchorUpdate<HandAnchor>) {
        Task(priority: .low) {
            guard let indexFinger = update.anchor.handSkeleton?.joint(.indexFingerTip),
                  let thumbTip = update.anchor.handSkeleton?.joint(.indexFingerMetacarpal) else {
                return
            }
            let indexFingerPos = matrix_multiply(update.anchor.originFromAnchorTransform, indexFinger.anchorFromJointTransform).translation
            let thumbTipPos = matrix_multiply(update.anchor.originFromAnchorTransform, thumbTip.anchorFromJointTransform).translation
            
            let currentDistanceIndexTipAndThumbTip = simd_distance(indexFingerPos, thumbTipPos)
            
            print("Gesture distance: \(currentDistanceIndexTipAndThumbTip)")
            
            // Check if the index finger and thumb tip are < minimumGestureDistance
            
            if currentDistanceIndexTipAndThumbTip < Float(minimumGestureDistance) {
                let now = Date()
                guard now > nextActionTime else { return }
                
                nextActionTime = now + actionDelayTime
                
                // Trigger your action here
            }
        }
    }
    
    func getPositionInFrontOfHand(distance: Float) -> SIMD3<Float> {
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

extension Transform {
    mutating func applyRotation(degrees: Float, around axis: SIMD3<Float>) {
        let radians = degrees * (.pi / 180)  // Convert degrees to radians
        let rotation = simd_quatf(angle: radians, axis: axis)  // Create quaternion rotation
        self.rotation = rotation * self.rotation  // Apply rotation to current transform
    }
}
