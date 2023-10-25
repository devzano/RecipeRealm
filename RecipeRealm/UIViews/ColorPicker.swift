//
//  ColorPicker.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 9/26/23.
//

import Foundation
import SwiftUI
import UIKit

// MARK: ColorPicker View
struct CustomColorPicker: View {
    @Binding var selectedAccentColor: Color
    @Binding var isColorPickerVisible: Bool
    
    var body: some View {
        ColorPicker("Pick Your Color", selection: $selectedAccentColor)
            .padding()
            .onChange(of: selectedAccentColor) { newColor in
                UserDefaults.standard.setColor(newColor, forKey: selectedAccentColorKey)
            }
    }
}

extension UserDefaults {
    func setColor(_ color: Color, forKey key: String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
            set(data, forKey: key)
        } catch {
            print("Error archiving color: \(error.localizedDescription)")
        }
    }
    
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key) else { return nil }
        do {
            guard let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else { return nil }
            return Color(uiColor)
        } catch {
            print("Error unarchiving color: \(error.localizedDescription)")
            return nil
        }
    }
}
