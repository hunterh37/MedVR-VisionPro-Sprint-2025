//
//  ImmersiveView.swift
//  RealityViewAttachmentSample
//
//  Created by Hunter Harris on 3/25/25.
//

import SwiftUI
import RealityKit

/* Global entities */
var rootEntity = Entity()
var floorEntity = ModelEntity()
var leftHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 0)
var rightHandEntity = ModelEntity(mesh: .generateSphere(radius: 0.04), materials: [UnlitMaterial(color: .green)], collisionShape: .generateSphere(radius: 0.04), mass: 0)
var rightHandIntermediate = Entity()

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    
    @ObservedObject var gestureModel: HandGestureModel = HandGestureModelContainer.handGestureModel
    
    @State var displayText = "Hello World"
    @State var showDisplayTextAttachmentView = true
    
    private let displayTextAttachmentName = "displayTextAttachmentName"

    var body: some View {
        RealityView { content, attachments in
            rootEntity = ModelEntity()
            content.add(rootEntity)
            
            // RealityView Attachment: Step 2
            // Register the new attachment view for 'displayTextAttachmentName'
            if let displayTextAttachmentView = attachments.entity(for: displayTextAttachmentName) {
                displayTextAttachmentView.components.set(BillboardComponent())
                rightHandIntermediate.addChild(displayTextAttachmentView)
            }
        } update: { content, attachments in
            // Optional step: update the displayTextAttachmentName visibility
            if let displayTextAttachmentView = attachments.entity(for: displayTextAttachmentName) {
                displayTextAttachmentView.isEnabled = showDisplayTextAttachmentView
                
                // Set an offset so the view appears beside hand
                displayTextAttachmentView.position = .init(x: 0, y: 0.03, z: 0.1)
            }
        } attachments: {
            // RealityView Attachment: Step 1
            // Define the SwiftUI View that will be displayed for 'displayTextAttachmentName'
            Attachment(id: displayTextAttachmentName) {
                return Text(displayText)
                    .font(.extraLargeTitle)
                    .padding()
                    .background(.red)
                    .glassBackgroundEffect()
            }
        }
        // Required for HandTracking: Start the HandTrackingProvider
        .task {
            await gestureModel.start()
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
