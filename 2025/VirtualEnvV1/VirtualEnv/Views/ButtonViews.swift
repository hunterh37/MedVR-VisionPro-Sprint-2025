//
//  ButtonViews.swift
//  VirtualEnv
//
//  Created by Dat Nguyen on 3/18/25.
//

import SwiftUI

struct ButtonViews: View {
    @Environment(AppModel.self) private var appModel

    var immersiveSpaceString: AppModel.immersiveSpaceString
    var stringName: String
    

    var body: some View {
        Button {
            Task { appModel.immersiveSpaceName = immersiveSpaceString}

        } label: {
            Text(stringName)
        }
        .disabled(
            appModel.immersiveSpaceState == .inTransition
                || appModel.immersiveSpaceState
                    == .open
        )
        .animation(.none, value: 0)
        .fontWeight(.semibold)
        .foregroundColor(
            appModel.immersiveSpaceName == immersiveSpaceString ? .yellow : .white
               )
    }
}

