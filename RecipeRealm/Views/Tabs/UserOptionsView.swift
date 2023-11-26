//
//  UserOptionsView.swift
//  RecipeRealm
//
//  Created by Ruben Manzano on 10/12/23.
//

import SwiftUI

struct UserOptionsView: View {
    @EnvironmentObject var appStates: AppStates

    var body: some View {
        Form {
            Section(header:
                Text("Change Recipe View")
                    .foregroundColor(appStates.selectedAccentColor)
            ) {
                Button(action: {
                    appStates.isListView.toggle()
                    UserDefaults.standard.set(appStates.isListView, forKey: selectedViewKey)
                }) {
                    HStack {
                        Label(appStates.isListView ? "Grid View" : "List View", systemImage: appStates.isListView ? "square.grid.2x2.fill" : "list.bullet")
                        Spacer()
                        Image(systemName: "chevron.right.circle.fill")
                            .rotationEffect(.degrees(appStates.isListView ? 0 : 180))
                    }
                }.buttonStyle(ToggleButtonStyle())
            }
            
            Section(header:
                Text("Change Tint Color")
                    .foregroundColor(appStates.selectedAccentColor)
            ) {
                HStack {
                    CustomColorPicker(selectedAccentColor: $appStates.selectedAccentColor, isColorPickerVisible: $appStates.isColorPickerVisible)
                }.background(appStates.selectedAccentColor.cornerRadius(8).opacity(0.7))
            }
        }.foregroundColor(.primary)
    }
}

struct UserOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        UserOptionsView()
            .environmentObject(AppStates())
    }
}
