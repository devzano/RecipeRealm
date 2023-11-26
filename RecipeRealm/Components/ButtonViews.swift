//
//  ButtonViews.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 11/23/23.
//

import Foundation
import SwiftUI
import UIKit

struct ToggleButtonStyle: ButtonStyle {
    @ObservedObject var appStates = AppStates()
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? appStates.selectedAccentColor.opacity(0.3) : appStates.selectedAccentColor.opacity(0.7))
            .foregroundColor(.primary)
            .cornerRadius(8)
    }
}
